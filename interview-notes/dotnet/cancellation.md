# CancellationToken

## Core sentence

**.NET cancellation is cooperative cancellation.**

Cancellation requested does not mean an arbitrary operation is forcibly terminated.

## Token vs Source

- `CancellationToken` observes/carries a cancellation signal.
- `CancellationTokenSource` produces/signals cancellation.

## ASP.NET Core request cancellation

```csharp
HttpContext.RequestAborted
```

represents cancellation associated with the HTTP request/client connection.

Kestrel/network infrastructure can detect an aborted request and signal the token. Detection is not guaranteed to be instantaneous.

The token should be propagated to cancellable downstream operations while their lifetime is tied to the request.

## CPU work

Passing a token alone does nothing:

```csharp
for (...)
{
    token.ThrowIfCancellationRequested();
    DoCpuWork();
}
```

The operation explicitly observes cancellation at a safe point. If CPU code never checks the token, it can continue to completion even after cancellation is requested.

## Task cancellation state

Cancellation is distinct from success and fault:

```text
Task
├── RanToCompletion
├── Faulted
└── Canceled
```

`ThrowIfCancellationRequested()` throws `OperationCanceledException`; in a correctly participating Task-based operation, cancellation can result in the Task ending in the Canceled state.

## Timeout

```csharp
using var cts =
    new CancellationTokenSource(TimeSpan.FromSeconds(5));
```

This represents an application-defined timeout. It does not trigger `RequestAborted`.

## Linked cancellation

A linked token can represent multiple cancellation reasons:

```text
client/request aborted ─┐
                        ├→ linked token
operation timeout ──────┘
```

## Business boundary

**HTTP request lifetime ≠ business-operation lifetime.**

After a durable business commit/handoff, required work should not necessarily stop merely because the client disconnected.

Example: after an Order is durably committed, publishing required `OrderCreated` work should not blindly depend on `RequestAborted`.

For durable side effects, patterns such as a Transactional Outbox can decouple business completion from the HTTP connection and avoid the DB-commit/message-publish dual-write gap.

## Interview answer

> CancellationToken carries cancellation intent; it does not kill the executing thread. Operations cooperate by observing the token at safe points or passing it to APIs that support cancellation. In ASP.NET Core, RequestAborted represents request-level cancellation, but required business work may need a different lifetime after a durable commit.

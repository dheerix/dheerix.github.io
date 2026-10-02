# CancellationToken

## Core sentence

**.NET cancellation is cooperative cancellation.**

Cancellation requested does not mean an arbitrary operation is forcibly terminated.

## Token vs Source

- `CancellationToken` observes a cancellation signal.
- `CancellationTokenSource` produces/signals cancellation.

## ASP.NET Core request cancellation

```csharp
HttpContext.RequestAborted
```

represents cancellation associated with the HTTP request/client connection.

Kestrel/network infrastructure can detect an aborted request and signal the token. Detection is not guaranteed to be instantaneous.

The token should be propagated to cancellable downstream operations.

## CPU work

Passing a token alone does nothing:

```csharp
for (...)
{
    token.ThrowIfCancellationRequested();
    DoCpuWork();
}
```

The operation explicitly observes cancellation at a safe point.

Cooperative cancellation allows cleanup and protects shared/in-progress state from arbitrary interruption.

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

For durable side effects, patterns such as an Outbox can decouple business completion from the HTTP connection.

## Interview answer

> CancellationToken carries cancellation intent; it does not kill the executing thread. Operations cooperate by observing the token at safe points or passing it to APIs that support cancellation. In ASP.NET Core, RequestAborted represents request-level cancellation, but business work may need a different lifetime after a durable commit.

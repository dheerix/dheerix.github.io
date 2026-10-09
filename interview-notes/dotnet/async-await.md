# Async / Await

## Core sentence

**`await` suspends the method, not the thread.**

## Task vs Thread

**Task**
- Represents an operation and its eventual completion, result, failure, or cancellation.
- Is not a thread.

**Thread**
- Execution resource that runs instructions.
- ASP.NET Core commonly executes application code using thread-pool threads.

Mental hook:

```text
Task   → what operation/completion am I waiting for?
Thread → what execution resource is running code now?
```

## I/O-bound work

For asynchronous network/database/file I/O:

1. A thread initiates the operation.
2. The API returns a Task.
3. If incomplete at `await`, the async method suspends.
4. The executing thread can return to the pool.
5. No .NET thread needs to sit waiting for the network operation.
6. Completion eventually makes the Task complete.
7. The continuation is scheduled; it need not use the original thread.

> `await` does not make I/O faster. It avoids occupying a thread while waiting for asynchronous I/O.

If the awaited Task is already complete, execution can continue synchronously without suspending.

## CPU-bound work and Task.Run

CPU work still needs CPU/thread execution.

`Task.Run` queues work to the ThreadPool; it does not remove its CPU cost. It is useful in UI applications for moving CPU-heavy work off the UI thread, but in ASP.NET Core it is generally not a scalability mechanism for CPU-bound request work.

Wrapping synchronous I/O in `Task.Run` is not true async I/O: a ThreadPool worker still blocks while waiting for the I/O.

## Sequential vs concurrent async I/O

Sequential:

```csharp
await GetUserAsync();
await GetOrdersAsync();
```

The second operation is not started until the first completes.

Concurrent independent operations:

```csharp
var userTask = GetUserAsync();
var ordersTask = GetOrdersAsync();

await Task.WhenAll(userTask, ordersTask);
```

Both operations are initiated before waiting for completion.

Before parallelizing/overlapping operations, ask:
- Are they independent from a business/invariant perspective?
- Does one depend on output/state from another?
- Is ordering required?
- What happens on partial failure?
- Can downstream systems handle the concurrent load?
- Do side effects require compensation or idempotency?

`Task.WhenAll` waits for all supplied Tasks to reach a terminal state. One failure does not automatically cancel the others.

## Bounded async concurrency

Async does not increase downstream capacity. Starting thousands of async operations can overwhelm connection pools, databases, APIs, memory, sockets, or rate limits.

`SemaphoreSlim` can bound concurrency:

```csharp
private readonly SemaphoreSlim _gate = new(3, 3);

await _gate.WaitAsync();
try
{
    await CallDatabaseAsync();
}
finally
{
    _gate.Release();
}
```

Waiting callers can wait asynchronously without occupying blocked ThreadPool workers.

## Synchronization: lock, Interlocked, SemaphoreSlim

`_count++` is a non-atomic read-modify-write operation. Concurrent interleaving can cause a race condition / lost update.

- `Interlocked.Increment(ref value)`: good fit for a simple atomic operation on one value.
- `lock`: mutual exclusion around a synchronous critical section. Code must coordinate on the same lock object.
- Protect the whole invariant, not just an individual write.
- `SemaphoreSlim.WaitAsync()`: useful for asynchronous mutual exclusion or bounded concurrency.

A normal `lock` / Monitor is thread-affine: the thread that acquires the monitor must release it. An `await` may suspend on one thread and resume on another, so a normal lock cannot span an await boundary.

`SemaphoreSlim` is permit-based rather than thread-owned, so the logical operation can retain a permit across an await and release it afterward.

## Async exceptions

An unhandled exception escaping an `async Task` / `async Task<T>` method faults the returned Task.

```text
async method throws
        ↓
returned Task becomes Faulted
        ↓
caller awaits Task
        ↓
await rethrows exception
        ↓
caller can catch it
```

A Task can end as:
- RanToCompletion
- Faulted
- Canceled

Avoid `async void` except framework-required cases such as event handlers. It gives the caller no Task to await for completion, failure, or cancellation.

## Interview answer

> An async method begins synchronously. When it awaits an incomplete asynchronous operation, the method suspends and the executing thread can return to the pool. When the operation completes, the continuation is scheduled. A Task represents the operation; it is not a thread. Async improves scalability for waiting I/O; it does not create CPU capacity or downstream capacity.

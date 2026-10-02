# Async / Await

## Core sentence

**`await` suspends the method, not the thread.**

## Task vs Thread

**Task**
- Represents an asynchronous operation and its eventual completion, result, failure, or cancellation.
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

## CPU-bound work

CPU work still needs CPU/thread execution.

`Task.Run` schedules work onto the thread pool; it does not remove its CPU cost. In ASP.NET Core, wrapping CPU-heavy server work in `Task.Run` is generally not a scalability solution.

Long-running CPU work may belong behind a durable job/worker architecture.

## Blocking

```csharp
.Result
.Wait()
```

synchronously block the executing thread while waiting.

## Sequential vs concurrent async I/O

Sequential:

```csharp
await GetUserAsync();
await GetOrdersAsync();
```

The second operation is not started until the first await completes.

Concurrent independent operations:

```csharp
var userTask = GetUserAsync();
var ordersTask = GetOrdersAsync();

await Task.WhenAll(userTask, ordersTask);
```

Both operations are initiated before waiting for completion.

Concurrency should still be bounded when downstream limits matter.

## Interview answer

> An async method begins synchronously. When it awaits an incomplete asynchronous operation, the method suspends and the executing thread can return to the pool. When the operation completes, the continuation is scheduled. A Task represents the operation; it is not a thread.

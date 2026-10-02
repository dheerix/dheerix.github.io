# Interview Notes

Compact revision notes extracted from hands-on practice. These are not lecture notes.

## How to use

For each topic, be able to:
1. State the mental model in one sentence.
2. Explain the runtime/algorithm behavior precisely.
3. Name the trade-off or failure mode.
4. Connect it to a related concept.

## DSA

- [Hash Map / Two Sum](dsa/hashmap.md)
- [Intervals / Merge Intervals](dsa/intervals.md)
- [Sliding Window](dsa/sliding-window.md)

## .NET / ASP.NET Core

- [Async / Await](dotnet/async-await.md)
- [Cancellation](dotnet/cancellation.md)
- [Dependency Injection Lifetimes](dotnet/dependency-injection.md)
- [Middleware / Request Pipeline](dotnet/middleware-pipeline.md)

## Connected runtime model

```text
HTTP request
   ↓
middleware async chain
   ↓
authentication / authorization
   ↓
controller / service
   ↓
Task + await
   ↓
async I/O without holding a thread while waiting
   ↓
CancellationToken propagates cancellation intent

DI controls object lifetimes throughout this execution:
Singleton → shared/concurrent
Scoped    → request/scope
Transient → resolution
```

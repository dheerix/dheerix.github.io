# Dependency Injection Lifetimes

## Lifetimes

### Singleton
One instance for the application's DI-container lifetime.

Implications:
- Long-lived.
- Shared across requests.
- Mutable state must be safe for concurrent access.

### Scoped
One instance per DI scope.

In a normal ASP.NET Core request, one request corresponds to one scope.

Common example: EF Core `DbContext`.

### Transient
A new instance each time the DI container **resolves** the service.

Transient means per resolution—not per request and not per method call.

## Captive dependency

Dangerous relationship:

```text
Singleton
   ↓
Scoped
```

A long-lived singleton can capture a dependency intended for a shorter scope.

If a singleton genuinely needs scoped work, create a scope for that operation using `IServiceScopeFactory` and resolve the scoped dependency within it.

For EF Core-specific creation scenarios, `IDbContextFactory<TContext>` may also fit.

## Safe direction

A scoped service depending on a singleton is normally fine because the dependency outlives the consumer.

## Singleton concurrency

All requests may reach the same singleton concurrently.

A mutable `Dictionary<TKey,TValue>` is not safe for concurrent writes.

Possible tools depend on intent:
- `ConcurrentDictionary` for concurrent key/value state.
- `IMemoryCache` for process-local caching.

## IMemoryCache

Provides in-process caching with cache-entry features such as expiration and eviction.

Important limitation:

```text
Pod A → its IMemoryCache
Pod B → its IMemoryCache
```

It is not automatically shared across application instances.

A distributed cache such as Redis solves a different architectural problem: shared cache state across processes/instances.

**Thread safety and distributed consistency are different concerns.**

## Interview answer

> Singleton is one shared long-lived instance, scoped is one instance per scope—normally per HTTP request—and transient is new per resolution. The key design issue is lifetime compatibility: a singleton should not capture a scoped dependency, and singleton state must be safe for concurrent request access.

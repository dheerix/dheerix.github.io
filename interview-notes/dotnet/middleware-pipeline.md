# ASP.NET Core Middleware / Request Pipeline

## Core mental model

Middleware is an **async chain of delegates around the request**.

A middleware can execute code before and after:

```csharp
await next(context);
```

Conceptually:

```text
REQUEST
   ↓
A — before
   ↓
B — before
   ↓
controller / endpoint
   ↑
B — after
   ↑
A — after
   ↓
RESPONSE
```

## Why exception middleware works

```csharp
try
{
    await next(context);
}
catch (Exception ex)
{
    // handle downstream exception
}
```

`next` represents downstream pipeline execution. An exception thrown by a controller propagates through the awaited async call chain back to the outer middleware.

This connects directly to the async/await mental model.

## Short-circuiting

A middleware can return without invoking `next`.

Downstream middleware/endpoints then do not execute.

## Authentication vs Authorization

**Authentication — Who are you?**
- Validate credentials/token.
- Establish the authenticated principal in `HttpContext.User`.

**Authorization — Are you allowed to do this?**
- Evaluate claims, roles, policies, and endpoint requirements.

Authentication should run before authorization because authorization relies on the established principal.

Do not describe JWT authentication as merely decoding a token; validation is the important step.

## 401 vs 403

- **401** → authentication required or not successfully established.
- **403** → authenticated identity is known but lacks permission.

## Use / Run / Map

**Use**
- Participate in/wrap the pipeline.
- Can invoke `next`.

**Run**
- Terminal middleware.
- No downstream `next`.

**Map**
- Branch the pipeline based on path.

Endpoint APIs such as `MapControllers` and `MapGet` register routed endpoints.

## Important nuance

If `Run` terminates downstream execution, upstream middleware still resumes after its awaited `next` completes.

```text
Logging before
    ↓
Run → response
    ↑
Logging after
```

## Interview answer

> ASP.NET Core builds an ordered async middleware pipeline. Each middleware can run before and after awaiting the next delegate, or short-circuit by not calling next. That nesting explains why order matters and why outer exception middleware can catch exceptions thrown by downstream controllers.

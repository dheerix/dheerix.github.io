# ASP.NET Core Action Results and Filters

## Action return types

### `Task<T>`

Strongly typed successful response data.

### `Task<IActionResult>`

Flexible HTTP result:

```csharp
return Ok(vehicle);
return NotFound();
return BadRequest();
```

The signature does not communicate the successful payload type.

### `Task<ActionResult<T>>`

Combines typed success data with HTTP action results.

```csharp
public async Task<ActionResult<Vehicle>> Get(int id)
{
    var vehicle = await service.GetVehicle(id);

    if (vehicle == null)
        return NotFound();

    return Ok(vehicle);
}
```

> `ActionResult<T>` gives a strongly typed success response while still allowing other HTTP action results.

Returning `Ok(vehicle)` is explicit and valid. Returning `vehicle` directly is also supported.

## Common HTTP results

```text
GET success        → 200 OK
POST created       → 201 Created
DELETE success     → 204 No Content
Bad input          → 400 Bad Request
Unauthenticated    → 401 Unauthorized
Forbidden          → 403 Forbidden
Missing resource   → 404 Not Found
```

For creation, `CreatedAtAction` can return 201 plus a Location header for the new resource.

## Idempotency

> Idempotent does not mean “same response every time.” It means repeating the operation has the same intended effect on server state.

DELETE can therefore be idempotent even if the first call returns 204 and a later call returns 404.

PUT is defined as idempotent. PATCH may or may not be idempotent depending on the operation represented.

Conventionally:
- PUT → replace/update the resource representation as a whole.
- PATCH → partial modification.

## Middleware vs filters

**Middleware**
- operates around the broader HTTP request pipeline;
- has `HttpContext`;
- appropriate for whole-request concerns.

Examples:
- global exception handling;
- correlation/request logging;
- total request timing.

**MVC/action filters**
- operate within MVC around controller/action execution;
- have action/controller-specific context;
- appropriate when the concern needs action arguments, controller/action metadata, or MVC result context.

Examples:
- action-specific timing;
- inspecting action arguments;
- action/result-specific behavior.

## Interview answer

> Middleware is HTTP-pipeline-oriented, while filters are MVC/controller-oriented. I use middleware for cross-cutting concerns that should wrap the request broadly, and filters when the concern specifically needs controller/action context.

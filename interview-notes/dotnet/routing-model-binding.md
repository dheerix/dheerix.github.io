# ASP.NET Core Routing, Model Binding, and Validation

## Core mental model

> Routing decides **which endpoint** handles the request. Model binding determines **what values** are passed to it. Validation determines whether those values are acceptable.

```text
HTTP request
   ↓
Routing — which endpoint?
   ↓
Binding / body input formatting — what arguments?
   ↓
Validation — are the values acceptable?
   ↓
Controller action
```

## Route constraints vs parameter types

```csharp
[HttpGet("{id:int}")]
public IActionResult Get(int id)
```

- `{id:int}` is a **route constraint** and participates in endpoint matching.
- `int id` is a .NET action parameter type used during binding/conversion.

Without the route constraint:

```csharp
[HttpGet("{id}")]
public IActionResult Get(int id)
```

`/banana` can match the route template and then fail conversion to `int`.

With `[ApiController]`, invalid model state normally results in an automatic 400 response.

With `{id:int}`, `/banana` does not match that route; if nothing else matches, the result is 404.

Literal route segments are more specific than parameter segments. Constrained parameters are more specific than unconstrained parameters.

## Binding vs validation

**Binding**
- obtains values from route, query, body, headers, etc.;
- converts them into .NET action parameters/models.

**Validation**
- evaluates the successfully produced values against validation rules.

Example:

```csharp
[Required]
public string Vin { get; set; }

[Range(1900, 2100)]
public int Year { get; set; }
```

`Vin = ""` and `Year = 1500` can be represented by their .NET types, but fail validation.

A value such as `"banana"` for an `int` is instead a conversion/binding failure.

Malformed JSON is encountered by the JSON input formatter/deserializer while the request body is being bound.

## Binding sources

Common explicit sources:

```text
[FromRoute]
[FromQuery]
[FromBody]
[FromHeader]
[FromServices]
```

With `[ApiController]`, ASP.NET Core can infer many binding sources.

## ApiController

Important behavior to remember:
- automatic 400 responses for invalid model state;
- binding-source inference;
- API-oriented error responses, commonly using Problem Details.

## Interview answer

> Routing selects the endpoint, route constraints participate in that selection, model binding obtains and converts request data into action arguments, and model validation checks whether the resulting values satisfy validation rules. With ApiController, invalid model state is normally converted into an automatic 400 response.

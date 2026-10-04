# ASP.NET Core Configuration and Options

## Core mental model

`IConfiguration` provides generic hierarchical configuration access.

The **Options pattern** binds related configuration into a strongly typed application concept.

Instead of scattering:

```csharp
configuration["Guardlane:Endpoint"]
```

bind:

```csharp
public class GuardlaneOptions
{
    public string Endpoint { get; set; }
    public int TimeoutSeconds { get; set; }
}
```

and consume typed options.

Benefits:
- grouped settings;
- compile-time property names;
- easier testing;
- validation;
- less configuration-key plumbing in business code.

## IOptions variants

### `IOptions<T>`
Stable options value; think application-lifetime value.

### `IOptionsSnapshot<T>`
Scoped options snapshot. In a typical web application, the scope is an HTTP request.

### `IOptionsMonitor<T>`
Suitable for long-lived/singleton consumers that need access to current options and can observe supported configuration reloads.

The underlying configuration provider must support/reload changes; the abstraction does not make every source dynamically reloadable.

## DI lifetime connection

`IOptionsSnapshot<T>` is scoped.

A singleton capturing it creates a lifetime mismatch:

```text
Singleton
   ↓ captures
IOptionsSnapshot<T> (scoped)
```

This is the same **captive dependency** concept as a singleton capturing another scoped dependency.

For a singleton that needs changing options, `IOptionsMonitor<T>` is the natural choice.

## Configuration validation

Configuration can be **type-correct but semantically invalid**.

Examples:
- `-5` is a valid `int`, but an invalid timeout.
- a nullable string can compile while a required endpoint is missing at runtime.

Use Options validation to express semantic rules.

```csharp
builder.Services
    .AddOptions<GuardlaneOptions>()
    .BindConfiguration("Guardlane")
    .Validate(o => o.TimeoutSeconds > 0)
    .Validate(o => !string.IsNullOrWhiteSpace(o.Endpoint))
    .ValidateOnStart();
```

`ValidateOnStart()` moves discovery of required configuration errors to application startup instead of the first request that happens to use the option.

## Interview answer

> IConfiguration gives generic configuration access, while the Options pattern binds related settings to typed objects. IOptions is a stable value, IOptionsSnapshot is scoped, and IOptionsMonitor is appropriate for long-lived consumers that need updated values. For required settings, I prefer startup validation so semantic configuration errors fail fast.

# Standalone Phlex Example with StyleCapsule

This example demonstrates using Phlex with StyleCapsule for CSS scoping, without Phoenix, in a standalone Elixir script.

## Running the Example

```bash
mix run examples/standalone/example.exs
```

Or directly with Elixir:

```bash
elixir examples/standalone/example.exs
```

## What This Example Shows

1. **Basic HTML Components**: Creating and rendering HTML components
2. **Component Composition**: Using components within other components
3. **SVG Integration**: Using SVG components within HTML
4. **StyleCapsule Integration**: Using StyleCapsule for CSS scoping
5. **Scoped CSS**: Component-level CSS that doesn't leak to other components
6. **Attributes**: Working with HTML attributes and styles

## Example Components

- `CardComponent`: A reusable card component with scoped CSS styles
- `IconComponent`: An SVG icon component with scoped styles
- `PageComponent`: The main page component that composes everything and injects scoped CSS

## Key Features Demonstrated

- Component definition with `use Phlex.HTML`
- Accessing assigns in `view_template/2`
- Using HTML elements (div, h1, p, etc.)
- Component composition and nesting
- SVG components
- StyleCapsule integration:
  - Generating capsule IDs
  - Scoping CSS with `Phlex.StyleCapsule.scope_css/3`
  - Adding `data-capsule` attributes with `Phlex.StyleCapsule.add_capsule_attr/2`
  - Injecting scoped CSS in the document head

## StyleCapsule Usage

StyleCapsule is available from [hex.pm](https://hex.pm/packages/style_capsule). The example uses `Mix.install` to fetch it automatically, or you can add it to your `mix.exs`:

```elixir
defp deps do
  [
    {:style_capsule, "~> 0.5"}
  ]
end
```

Each component defines its CSS styles using the `@component_styles` module attribute:

```elixir
@component_styles """
.card {
  padding: 1.5rem;
  border: 1px solid #e0e0e0;
  ...
}
"""
```

Then uses `Phlex.StyleCapsule` to:
1. Generate a capsule ID: `Phlex.StyleCapsule.capsule_id(__MODULE__)`
2. Scope the CSS: `Phlex.StyleCapsule.scope_css(@component_styles, __MODULE__)`
3. Add capsule attribute: `Phlex.StyleCapsule.add_capsule_attr(attrs, __MODULE__)`

This ensures that CSS styles are scoped to the component and won't conflict with other components' styles.

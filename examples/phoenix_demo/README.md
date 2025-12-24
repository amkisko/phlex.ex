# Phoenix Demo with Phlex and StyleCapsule

This example demonstrates using Phlex components with StyleCapsule CSS scoping in a Phoenix LiveView application.

## Setup

```bash
cd examples/phoenix_demo
mix deps.get
mix phx.server
```

Then visit http://localhost:4000

**Note:** This example uses `style_capsule` from [hex.pm](https://hex.pm/packages/style_capsule). It will be automatically fetched when you run `mix deps.get`.

## What This Example Shows

1. **Phlex Components in Phoenix**: Using Phlex components within Phoenix LiveView
2. **StyleCapsule Integration**: Scoped CSS for Phlex components
3. **Component Reusability**: Reusable Card component with encapsulated styles
4. **LiveView Integration**: Rendering Phlex components in LiveView templates

## Example Components

- `PhoenixDemoWeb.Components.Card`: A card component with scoped CSS styles
- `PhoenixDemoWeb.PageLive`: LiveView page that renders multiple cards

## Key Features Demonstrated

- Phlex component definition with `use Phlex.HTML`
- StyleCapsule CSS scoping:
  - Component-level CSS definitions
  - Automatic capsule ID generation
  - CSS scoping with `[data-capsule="..."]` selectors
  - Style injection in LiveView templates
- Component rendering in HEEx templates
- Multiple component instances with shared scoped styles

## StyleCapsule Usage

The Card component defines scoped CSS:

```elixir
@component_styles """
.card {
  padding: 1.5rem;
  border: 1px solid #e0e0e0;
  ...
}
"""
```

And uses `Phlex.StyleCapsule` helpers to:
1. Add `data-capsule` attributes automatically
2. Generate scoped CSS
3. Inject styles in the page template

This ensures component styles are isolated and don't conflict with global styles or other components.

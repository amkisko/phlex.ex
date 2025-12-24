# Phlex.Ex

[![Hex.pm](https://img.shields.io/hexpm/v/phlex)](https://hex.pm/packages/phlex) [![Hex.pm](https://img.shields.io/hexpm/dt/phlex)](https://hex.pm/packages/phlex) [![Test Status](https://github.com/amkisko/phlex.ex/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/phlex.ex/actions/workflows/test.yml)

Object-oriented web views in Elixir. Build HTML, SVG, and other markup views using Elixir's functional programming paradigm with component-based architecture.

**Migrating from the Ruby version?** This Elixir implementation follows the same philosophy as [Phlex](https://www.phlex.fun) but embraces Elixir's functional nature with explicit state passing.

## Features

- **Component-based architecture** - Build reusable HTML and SVG components
- **Type-safe** - Dialyzer support for type checking
- **Phoenix integration** - Works seamlessly with Phoenix and Phoenix LiveView
- **Standalone usage** - Can be used without Phoenix in plain Elixir applications
- **StyleCapsule integration** - Optional CSS scoping support via `style_capsule` package
- **Modern Elixir** - Uses Elixir 1.18+ features and patterns

## Installation

Add `phlex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phlex, "~> 0.1.0"}
  ]
end
```

For Phoenix integration, also ensure you have:

```elixir
{:phoenix, "~> 1.7"},
{:phoenix_live_view, "~> 0.20"}
```

For CSS scoping support, consider adding `style_capsule`:

```elixir
{:style_capsule, "~> 0.7.0"}
```

## Quick Start

### 1. Create a Component

```elixir
defmodule MyAppWeb.Components.Card do
  use Phlex.HTML

  def view_template(assigns, state) do
    div(state, [class: "card"], fn state ->
      h1(state, [class: "title"], Map.get(assigns, :title, "Card"))
      p(state, [], Map.get(assigns, :content, ""))
    end)
  end
end
```

### 2. Use in Phoenix LiveView

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    Phlex.Phoenix.to_rendered(
      MyAppWeb.Components.Card.render(%{title: "Hello", content: "World"})
    )
  end
end
```

### 3. Optional: Add CSS Scoping with StyleCapsule

For component-scoped CSS, integrate with `style_capsule`:

```elixir
defmodule MyAppWeb.Components.Card do
  use Phlex.HTML

  @component_styles """
  .card { padding: 1rem; border: 1px solid #ccc; }
  .title { font-size: 1.5rem; font-weight: bold; }
  """

  def view_template(assigns, state) do
    # Register styles
    capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id)

    # Add capsule attribute
    attrs = Phlex.StyleCapsule.add_capsule_attr([class: "card"], __MODULE__)

    div(state, attrs, fn state ->
      h1(state, [class: "title"], Map.get(assigns, :title, "Card"))
    end)
  end
end
```

Then render styles in your layout:

```heex
<body>
  <%= @inner_content %>
  <%= raw StyleCapsule.Phoenix.render_all_runtime_styles() %>
</body>
```

## Usage

Phlex components use explicit state passing, following Elixir's functional programming style. The `view_template/2` function receives assigns and a state struct, then returns the updated state.

### Basic HTML Component

```elixir
defmodule MyApp.Components.Card do
  use Phlex.HTML

  def view_template(assigns, state) do
    div(state, [class: "card"], fn state ->
      h1(state, [class: "title"], Map.get(assigns, :title, "Default"))
      p(state, [], Map.get(assigns, :content, ""))
    end)
  end
end

MyApp.Components.Card.render(%{title: "Hello", content: "World"})
# => "<div class=\"card\"><h1 class=\"title\">Hello</h1><p>World</p></div>"
```

### SVG Component

```elixir
defmodule MyApp.Components.Icon do
  use Phlex.SVG

  def view_template(_assigns, state) do
    svg(state, [viewBox: "0 0 24 24"], fn state ->
      circle(state, [cx: "12", cy: "12", r: "10"])
    end)
  end
end
```

### Phoenix LiveView Integration

When using Phlex components in LiveView, convert the HTML string to a `Phoenix.LiveView.Rendered` struct:

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    Phlex.Phoenix.to_rendered(
      MyAppWeb.Components.Card.render(assigns)
    )
  end
end
```

### StyleCapsule Integration

For component-scoped CSS, Phlex provides helpers through `Phlex.StyleCapsule`. Register your styles and add capsule attributes to scope your CSS automatically:

```elixir
defmodule MyAppWeb.Components.Card do
  use Phlex.HTML

  @component_styles """
  .card { padding: 1rem; }
  .title { font-weight: bold; }
  """

  def view_template(assigns, state) do
    # Register styles with StyleCapsule
    capsule_id = Phlex.StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    # Add data-capsule attribute
    attrs = Phlex.StyleCapsule.add_capsule_attr([class: "card"], __MODULE__)

    div(state, attrs, fn state ->
      h1(state, [class: "title"], Map.get(assigns, :title, "Card"))
    end)
  end
end
```

Alternatively, use `StyleCapsule.PhlexComponent` for automatic integration:

```elixir
defmodule MyAppWeb.Components.Card do
  use StyleCapsule.PhlexComponent

  @component_styles """
  .card { padding: 1rem; }
  .title { font-weight: bold; }
  """

  defp render_template(assigns, attrs, state) do
    div(state, attrs, fn state ->
      h1(state, [class: "title"], Map.get(assigns, :title, "Card"))
    end)
  end
end
```

## Example Applications

A complete Phoenix example application is available in `examples/phoenix_demo/`. It demonstrates Phlex components, Phoenix LiveView integration, and StyleCapsule CSS scoping.

To run the example:

```bash
cd examples/phoenix_demo
mix deps.get
mix phx.server
```

Then visit http://localhost:4000 to see Phlex in action.

## Development

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run all quality checks
mix quality

# Format code
mix format

# Run code analysis
mix credo --strict

# Run type checking
mix dialyzer
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amkisko/phlex.ex

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Requirements

- Elixir >= 1.18
- Phoenix >= 1.7 (optional, for Phoenix integration)
- Phoenix LiveView >= 0.20 (optional, for LiveView integration)
- StyleCapsule >= 0.7.0 (optional, for CSS scoping support)

## Thanks

This project was inspired by and references several excellent projects:

- **[Phlex](https://www.phlex.fun)** ([GitHub](https://github.com/yippee-fun/phlex)) - The original Ruby gem for building object-oriented web views that inspired this Elixir implementation
- **[Phoenix Framework](https://www.phoenixframework.org)** - The web framework that makes building real-time applications in Elixir a joy
- **[Surface](https://surface-ui.org)** ([GitHub](https://github.com/surface-ui/surface)) - A component-based library for Phoenix that provided architectural inspiration

## License

The library is available as open source under the terms of the [MIT License](LICENSE.md).

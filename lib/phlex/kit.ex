defmodule Phlex.Kit do
  @moduledoc """
  Registers nested Phlex components as callable helpers.

  Elixir counterpart to Phlex Ruby `Kit`. Because Elixir has no `const_added`
  hook, kits register components explicitly with `kit_component/1`:

      defmodule MyApp.Components do
        use Phlex.Kit

        defmodule SayHi do
          use Phlex.HTML
          defstruct [:name, times: 1]

          def view_template(assigns, state) do
            # ...
          end
        end

        kit_component SayHi
      end

  Import or `use` the kit from another component to get `say_hi/1-3` helpers.
  Calling those helpers outside a render that starts with `%Phlex.SGML.State{}`
  raises, matching Ruby kit guard behavior.
  """

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :phlex_kit_components, accumulate: true)
      @before_compile Phlex.Kit
      import Phlex.Kit, only: [kit_component: 1, kit_component: 2]

      defmacro __using__(_opts) do
        quote do
          import unquote(__MODULE__)
        end
      end
    end
  end

  @doc """
  Registers a component module under a helper name.

  Options:
  - `:as` - atom helper name (default: underscored last module segment)
  """
  defmacro kit_component(module_alias, opts \\ []) do
    quote do
      @phlex_kit_components {unquote(module_alias), unquote(opts)}
    end
  end

  defmacro __before_compile__(env) do
    components = Module.get_attribute(env.module, :phlex_kit_components) || []

    defs =
      Enum.map(components, fn {module_alias, opts} ->
        module = Macro.expand(module_alias, env)
        helper_name = helper_name(module, opts)
        capital_name = module |> Module.split() |> List.last()

        quote do
          def unquote(helper_name)(state_or_assigns, assigns_or_opts \\ nil, opts \\ nil)

          def unquote(helper_name)(%Phlex.SGML.State{} = state, assigns_or_opts, opts) do
            assigns = assigns_or_opts || %{}
            opts = opts || []
            Phlex.Kit.render_component(state, unquote(module), assigns, opts)
          end

          def unquote(helper_name)(_assigns, _opts, _extra) do
            Phlex.Kit.render_outside_context!(unquote(capital_name))
          end
        end
      end)

    quote do
      (unquote_splicing(defs))
    end
  end

  @doc false
  def render_component(state, module, assigns, opts) do
    assigns = Map.new(assigns)
    component = struct(module, Map.to_list(assigns)) |> Map.put(:_assigns, assigns)
    module.__phlex_call__(component, state, opts)
  end

  @doc false
  def render_outside_context!(name) do
    raise "You can't call `#{name}' outside of a Phlex rendering context."
  end

  defp helper_name(module, opts) do
    case Keyword.get(opts, :as) do
      nil ->
        module
        |> Module.split()
        |> List.last()
        |> Macro.underscore()
        |> String.to_atom()

      name when is_atom(name) ->
        name
    end
  end
end

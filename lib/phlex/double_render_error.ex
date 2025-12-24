defmodule Phlex.DoubleRenderError do
  @moduledoc """
  Raised when attempting to render a component more than once.

  Components can only be rendered once per instance.
  """
  defexception [:message, :component]

  def exception(opts) when is_list(opts) do
    component = Keyword.get(opts, :component)
    message = Keyword.get(opts, :message) || "You can't render a #{inspect(component)} more than once."

    %__MODULE__{
      message: message,
      component: component
    }
  end
end

defprotocol Phlex.SGML.SafeObject do
  @moduledoc """
  Protocol for objects that are safe to render in an SGML context.

  Objects implementing this protocol must provide a `to_safe_string/1` function
  that returns a string representation that is safe to output without escaping.

  ## Example

      defimpl Phlex.SGML.SafeObject, for: MySafeType do
        def to_safe_string(value), do: value.content
      end
  """

  @doc """
  Converts a safe object to a safe string representation.
  """
  def to_safe_string(value)
end

defmodule Phlex.SGML.SafeValue do
  @moduledoc """
  A wrapper for string values that are marked as safe for HTML output.

  ## Example

      safe_value = Phlex.SGML.SafeValue.new("<strong>Hello</strong>")
      Phlex.SGML.append_raw(state, safe_value)
  """

  defstruct [:content]

  defimpl Phlex.SGML.SafeObject do
    def to_safe_string(%Phlex.SGML.SafeValue{content: content}) when is_binary(content) do
      content
    end
  end

  @doc """
  Creates a new SafeValue from a string.
  """
  def new(content) when is_binary(content) do
    %__MODULE__{content: content}
  end

  def new(_), do: raise(ArgumentError, "SafeValue.new/1 expects a binary string")
end

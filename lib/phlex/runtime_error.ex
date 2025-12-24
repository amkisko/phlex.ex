defmodule Phlex.RuntimeError do
  @moduledoc """
  Raised when a runtime error occurs during Phlex rendering.
  """
  defexception [:message]

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(opts) when is_list(opts) do
    message = Keyword.get(opts, :message, "Runtime error")
    %__MODULE__{message: message}
  end
end

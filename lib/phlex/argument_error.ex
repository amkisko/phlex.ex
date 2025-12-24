defmodule Phlex.ArgumentError do
  @moduledoc """
  Raised when invalid arguments are provided to Phlex functions.
  """
  defexception [:message]

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(opts) when is_list(opts) do
    message = Keyword.get(opts, :message, "Invalid argument")
    %__MODULE__{message: message}
  end
end

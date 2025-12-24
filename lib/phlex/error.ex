defmodule Phlex.Error do
  @moduledoc """
  Base error module for Phlex.

  All Phlex-specific errors should use this module.
  """
  defexception [:message]

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(opts) when is_list(opts) do
    message = Keyword.get(opts, :message, "Phlex error")
    %__MODULE__{message: message}
  end
end

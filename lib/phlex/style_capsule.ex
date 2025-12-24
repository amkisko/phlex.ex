defmodule Phlex.StyleCapsule do
  @moduledoc """
  Integration helper for using StyleCapsule with Phlex components.

  This module provides utilities to integrate StyleCapsule CSS scoping
  with Phlex components.

  Note: This requires the `style_capsule` package to be installed.
  Add it to your dependencies:

      {:style_capsule, "~> 0.5"}
  """

  @doc """
  Generates a capsule ID for a component module.
  """
  def capsule_id(module) do
    ensure_style_capsule!()
    StyleCapsule.capsule_id(module)
  end

  @doc """
  Scopes CSS for a component.
  """
  def scope_css(css, module_or_capsule_id, opts \\ []) do
    ensure_style_capsule!()

    capsule_id =
      if is_binary(module_or_capsule_id) do
        module_or_capsule_id
      else
        StyleCapsule.capsule_id(module_or_capsule_id)
      end

    StyleCapsule.scope_css(css, capsule_id, opts)
  end

  @doc """
  Wraps HTML content with a capsule element.
  """
  def wrap(html, module_or_capsule_id, opts \\ []) do
    ensure_style_capsule!()

    capsule_id =
      if is_binary(module_or_capsule_id) do
        module_or_capsule_id
      else
        StyleCapsule.capsule_id(module_or_capsule_id)
      end

    StyleCapsule.wrap(html, capsule_id, opts)
  end

  @doc """
  Adds data-capsule attribute to a state's attributes list.
  """
  def add_capsule_attr(attrs, module) when is_list(attrs) do
    capsule_id = capsule_id(module)
    Keyword.put(attrs, :"data-capsule", capsule_id)
  end

  def add_capsule_attr(attrs, module) when is_map(attrs) do
    capsule_id = capsule_id(module)
    Map.put(attrs, "data-capsule", capsule_id)
  end

  @doc """
  Generates a style tag with scoped CSS.
  """
  def style_tag(css, module_or_capsule_id, opts \\ []) do
    scoped_css = scope_css(css, module_or_capsule_id, opts)
    ~s(<style>#{scoped_css}</style>)
  end

  defp ensure_style_capsule! do
    case Code.ensure_loaded(StyleCapsule) do
      {:module, StyleCapsule} ->
        :ok

      {:error, :nofile} ->
        raise """
        StyleCapsule is not available. Please add it to your dependencies:

            {:style_capsule, "~> 0.5"}

        Then run: mix deps.get
        """
    end
  end
end

defmodule PhoenixDemoWeb.ErrorHTML do
  use PhoenixDemoWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates line and add the templates
  # to your error directory:
  #
  #   * lib/phoenix_demo_web/controllers/error_html/404.html.heex
  #   * lib/phoenix_demo_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

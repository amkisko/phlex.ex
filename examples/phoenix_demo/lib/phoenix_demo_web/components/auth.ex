defmodule PhoenixDemoWeb.Components.Auth do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .auth-container {
    min-height: 100vh;
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
  }

  .auth-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
    padding: 3rem;
    max-width: 420px;
    width: 100%;
  }

  .auth-title {
    font-size: 32px;
    font-weight: 600;
    color: #1d1d1f;
    text-align: center;
    margin-bottom: 0.5rem;
    letter-spacing: -0.02em;
  }

  .auth-subtitle {
    color: #86868b;
    text-align: center;
    margin-bottom: 2rem;
    font-size: 17px;
  }

  .auth-form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .auth-field {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .auth-label {
    font-size: 13px;
    font-weight: 500;
    color: #1d1d1f;
  }

  .auth-input {
    width: 100%;
    padding: 0.875rem 1rem;
    border: 1px solid rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    font-size: 17px;
    transition: border-color 0.2s;
    background: rgba(255, 255, 255, 0.8);
  }

  .auth-input:focus {
    outline: none;
    border-color: #0071e3;
  }

  .auth-button {
    width: 100%;
    padding: 0.875rem;
    background: #0071e3;
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 17px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    margin-top: 0.5rem;
  }

  .auth-button:hover {
    background: #0077ed;
  }

  .auth-info {
    margin-top: 1.5rem;
    padding-top: 1.5rem;
    border-top: 1px solid rgba(0, 0, 0, 0.1);
    text-align: center;
    font-size: 12px;
    color: #86868b;
  }

  .auth-demo-box {
    background: rgba(0, 113, 227, 0.1);
    border: 1px solid rgba(0, 113, 227, 0.2);
    border-radius: 10px;
    padding: 1rem;
    margin-bottom: 1.5rem;
  }

  .auth-demo-title {
    font-size: 13px;
    font-weight: 600;
    color: #0071e3;
    margin-bottom: 0.5rem;
  }

  .auth-demo-text {
    font-size: 12px;
    color: #0071e3;
    margin: 0.25rem 0;
  }
  """

  def render_template(assigns, attrs, state) do
    form_data = Map.get(assigns, :form_data, %{})

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "auth-container")

    div(state, final_attrs, fn state ->
      state
      |> div([class: "auth-card"], fn state ->
        state
        |> h1([class: "auth-title"], "Welcome to DemoApp")
        |> p([class: "auth-subtitle"], "Sign in to your account")
        |> render_form(form_data)
        |> render_demo_info(form_data)
      end)
    end)
  end

  defp render_form(state, form_data) do
    form(state, [class: "auth-form", phx_submit: "login"], fn state ->
      state
      |> div([class: "auth-field"], fn state ->
        state
        |> label([class: "auth-label", for: "email"], "Email Address")
        |> input([
          type: "email",
          id: "email",
          name: "email",
          value: Map.get(form_data, :email, ""),
          class: "auth-input",
          required: true,
          placeholder: "Enter your email"
        ])
      end)
      |> div([class: "auth-field"], fn state ->
        state
        |> label([class: "auth-label", for: "password"], "Password")
        |> input([
          type: "password",
          id: "password",
          name: "password",
          value: Map.get(form_data, :password, ""),
          class: "auth-input",
          required: true,
          placeholder: "Enter your password"
        ])
      end)
      |> button([type: "submit", class: "auth-button"], "Sign In")
    end)
  end

  defp render_demo_info(state, form_data) do
    div(state, [class: "auth-info"], fn state ->
      state
      |> p([], fn state ->
        state
        |> strong([], "Demo Credentials:")
        |> br([])
        |> Phlex.SGML.append_text("Email: #{Map.get(form_data, :email, "")}")
        |> br([])
        |> Phlex.SGML.append_text("Password: [hidden]")
      end)
    end)
  end
end

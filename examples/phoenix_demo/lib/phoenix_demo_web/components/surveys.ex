defmodule PhoenixDemoWeb.Components.Surveys do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .surveys-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .surveys-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2.5rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
  }

  .surveys-form {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  .surveys-fieldset {
    border: none;
    padding: 0;
    margin: 0;
  }

  .surveys-legend {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1d1d1f;
    margin-bottom: 1rem;
  }

  .surveys-field {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .surveys-label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .surveys-input {
    width: 100%;
    padding: 0.875rem 1rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    font-size: 15px;
    background: #ffffff;
    transition: all 0.2s ease;
  }

  .surveys-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
  }

  .surveys-textarea {
    width: 100%;
    padding: 0.875rem 1rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.9375rem;
    font-family: inherit;
    resize: vertical;
    transition: border-color 0.2s;
  }

  .surveys-textarea:focus {
    outline: none;
    border-color: #8fd3f4;
  }

  .surveys-select {
    width: 100%;
    padding: 0.875rem 1rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.9375rem;
    background: white;
    transition: border-color 0.2s;
  }

  .surveys-select:focus {
    outline: none;
    border-color: #8fd3f4;
  }

  .surveys-radio-group,
  .surveys-checkbox-group {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .surveys-radio-item,
  .surveys-checkbox-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .surveys-radio,
  .surveys-checkbox {
    width: 1rem;
    height: 1rem;
    cursor: pointer;
  }

  .surveys-radio-label,
  .surveys-checkbox-label {
    font-size: 0.9375rem;
    color: #374151;
    cursor: pointer;
  }

  .surveys-range-container {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .surveys-range {
    width: 100%;
    height: 0.5rem;
    border-radius: 0.25rem;
    background: #e5e7eb;
    outline: none;
    -webkit-appearance: none;
  }

  .surveys-range::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 1.25rem;
    height: 1.25rem;
    border-radius: 50%;
    background: #8fd3f4;
    cursor: pointer;
  }

  .surveys-range::-moz-range-thumb {
    width: 1.25rem;
    height: 1.25rem;
    border-radius: 50%;
    background: #8fd3f4;
    cursor: pointer;
    border: none;
  }

  .surveys-range-labels {
    display: flex;
    justify-content: space-between;
    font-size: 0.75rem;
    color: #6b7280;
  }

  .surveys-submit {
    width: 100%;
    padding: 1rem;
    background: #0071e3;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 17px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
    margin-top: 1rem;
  }

  .surveys-submit:hover {
    background: #0077ed;
    transform: translateY(-1px);
  }
  """

  def render_template(assigns, attrs, state) do
    recommend_score = Map.get(assigns, :recommend_score, 5)

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "surveys-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "surveys-card"], fn state ->
          form(state, [class: "surveys-form", phx_submit: "submit_survey"], fn state ->
            state
            |> render_personal_info()
            |> render_rating()
            |> render_likes()
            |> render_frequency()
            |> render_recommend(recommend_score)
            |> render_comments()
            |> button([type: "submit", class: "surveys-submit"], "Submit Survey")
          end)
        end)
      end)
    end)
  end

  defp render_personal_info(state) do
    fieldset(state, [class: "surveys-fieldset"], fn state ->
      state
      |> legend([class: "surveys-legend"], "Personal Information")
      |> div([class: "surveys-field"], fn state ->
        state
        |> label([class: "surveys-label", for: "name"], "Full Name")
        |> input([
          type: "text",
          id: "name",
          name: "survey[name]",
          class: "surveys-input",
          required: true
        ])
      end)
      |> div([class: "surveys-field"], fn state ->
        state
        |> label([class: "surveys-label", for: "email"], "Email Address")
        |> input([
          type: "email",
          id: "email",
          name: "survey[email]",
          class: "surveys-input",
          required: true
        ])
      end)
    end)
  end

  defp render_rating(state) do
    ratings = [{"excellent", "Excellent"}, {"good", "Good"}, {"fair", "Fair"}, {"poor", "Poor"}]

    fieldset(state, [class: "surveys-fieldset"], fn state ->
      state
      |> legend([class: "surveys-legend"], "How would you rate your overall experience?")
      |> div([class: "surveys-radio-group"], fn state ->
        Enum.reduce(ratings, state, fn {value, label}, acc_state ->
          div(acc_state, [class: "surveys-radio-item"], fn state ->
            state
            |> input([
              type: "radio",
              id: "rating-#{value}",
              name: "survey[rating]",
              value: value,
              class: "surveys-radio",
              required: true
            ])
            |> label([class: "surveys-radio-label", for: "rating-#{value}"], label)
          end)
        end)
      end)
    end)
  end

  defp render_likes(state) do
    likes = [
      {"cleanliness", "Cleanliness"},
      {"service", "Customer Service"},
      {"location", "Location"},
      {"amenities", "Amenities"},
      {"price", "Value for Money"},
      {"food", "Food Quality"}
    ]

    fieldset(state, [class: "surveys-fieldset"], fn state ->
      state
      |> legend([class: "surveys-legend"], "What did you like most? (Select all that apply)")
      |> div([class: "surveys-checkbox-group"], fn state ->
        Enum.reduce(likes, state, fn {value, label}, acc_state ->
          div(acc_state, [class: "surveys-checkbox-item"], fn state ->
            state
            |> input([
              type: "checkbox",
              id: "like-#{value}",
              name: "survey[likes][]",
              value: value,
              class: "surveys-checkbox"
            ])
            |> label([class: "surveys-checkbox-label", for: "like-#{value}"], label)
          end)
        end)
      end)
    end)
  end

  defp render_frequency(state) do
    div(state, [class: "surveys-field"], fn state ->
      state
      |> label([class: "surveys-label", for: "visit_frequency"], "How often do you stay with us?")
      |> select([id: "visit_frequency", name: "survey[visit_frequency]", class: "surveys-select", required: true], fn state ->
        state
        |> option([value: ""], "Select frequency")
        |> option([value: "first-time"], "First time")
        |> option([value: "occasionally"], "Occasionally (1-2 times/year)")
        |> option([value: "regularly"], "Regularly (3-5 times/year)")
        |> option([value: "frequently"], "Frequently (6+ times/year)")
      end)
    end)
  end

  defp render_recommend(state, recommend_score) do
    div(state, [class: "surveys-field"], fn state ->
      state
      |> label([class: "surveys-label", for: "recommend_score"], fn state ->
        state
        |> Phlex.SGML.append_text("How likely are you to recommend us? (0-10) ")
        |> output([for: "recommend_score", id: "recommend_output", style: "font-weight: 600; color: #8fd3f4; margin-left: 0.5rem;"], "#{recommend_score}")
      end)
      |> div([class: "surveys-range-container"], fn state ->
        state
        |> input([
          type: "range",
          id: "recommend_score",
          name: "survey[recommend_score]",
          min: "0",
          max: "10",
          value: "#{recommend_score}",
          class: "surveys-range",
          phx_change: "update_recommend_score"
        ])
        |> script([], Phlex.SGML.safe("""
          (function() {
            const slider = document.getElementById('recommend_score');
            const output = document.getElementById('recommend_output');
            if (slider && output) {
              slider.addEventListener('input', function() {
                output.textContent = this.value;
              });
            }
          })();
        """))
        |> div([class: "surveys-range-labels"], fn state ->
          state
          |> span([], "0 - Not likely")
          |> span([], "10 - Very likely")
        end)
      end)
    end)
  end

  defp render_comments(state) do
    div(state, [class: "surveys-field"], fn state ->
      state
      |> label([class: "surveys-label", for: "comments"], "Additional Comments or Suggestions")
      |> textarea([
        id: "comments",
        name: "survey[comments]",
        rows: "4",
        class: "surveys-textarea",
        placeholder: "Please share any additional feedback..."
      ], "")
    end)
  end
end

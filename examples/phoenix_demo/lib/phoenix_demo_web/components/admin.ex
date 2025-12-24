defmodule PhoenixDemoWeb.Components.Admin do
  use PhoenixDemoWeb.Components.Base, namespace: :admin

  @component_styles """
  .admin-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .admin-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 2rem;
  }

  .admin-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    margin-bottom: 1.5rem;
  }

  .admin-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .admin-table {
    width: 100%;
    border-collapse: collapse;
  }

  .admin-table-header {
    border-bottom: 1px solid #e5e7eb;
    background: #f9fafb;
  }

  .admin-table-header-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
  }

  .admin-table-row {
    border-bottom: 1px solid #f3f4f6;
  }

  .admin-table-row:hover {
    background-color: #f9fafb;
  }

  .admin-table-cell {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
    color: #1d1d1f;
  }

  .admin-status-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .admin-status-active {
    background: #d1fae5;
    color: #065f46;
  }

  .admin-status-inactive {
    background: #f3f4f6;
    color: #374151;
  }

  .admin-button {
    color: #667eea;
    font-size: 0.875rem;
    font-weight: 500;
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    transition: color 0.2s;
  }

  .admin-button:hover {
    color: #5568d3;
  }

  .admin-form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .admin-field {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .admin-label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .admin-input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.9375rem;
    transition: border-color 0.2s;
  }

  .admin-input:focus {
    outline: none;
    border-color: #667eea;
  }

  .admin-checkbox-container {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .admin-checkbox {
    width: 1rem;
    height: 1rem;
    cursor: pointer;
  }

  .admin-checkbox-label {
    font-size: 0.875rem;
    color: #374151;
    cursor: pointer;
  }

  .admin-submit {
    width: 100%;
    padding: 0.875rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }

  .admin-submit:hover {
    background: #5568d3;
  }

  .admin-svg-container {
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .admin-svg {
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
  }

  .admin-canvas {
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
    width: 100%;
  }

  .admin-media {
    width: 100%;
    border-radius: 0.5rem;
  }

  .admin-media-text {
    font-size: 0.875rem;
    color: #6b7280;
    margin-top: 1rem;
  }
  """

  def render_template(assigns, attrs, state) do
    users = Map.get(assigns, :users, [])
    settings = Map.get(assigns, :settings, %{})
    monthly_revenue = Map.get(assigns, :monthly_revenue, [])
    occupancy_data = Map.get(assigns, :occupancy_data, [])

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "admin-container")

    div(state, final_attrs, fn state ->
      state
      |> div([class: "container"], fn state ->
        state
        |> div([class: "admin-grid"], fn state ->
          state
          |> div([], fn state ->
            state
            |> render_user_management(users)
            |> render_svg_demo(monthly_revenue)
            |> render_canvas_demo(occupancy_data)
          end)
          |> div([], fn state ->
            state
            |> render_settings(settings)
            |> render_audio_demo()
            |> render_video_demo()
          end)
        end)
      end)
    end)
  end

  defp render_user_management(state, users) do
    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "User Management")
      |> div([style: "overflow-x: auto;"], fn state ->
        table(state, [class: "admin-table"], fn state ->
          state
          |> thead([class: "admin-table-header"], fn state ->
            tr(state, [], fn state ->
              state
              |> th([class: "admin-table-header-cell"], "ID")
              |> th([class: "admin-table-header-cell"], "Name")
              |> th([class: "admin-table-header-cell"], "Email")
              |> th([class: "admin-table-header-cell"], "Role")
              |> th([class: "admin-table-header-cell"], "Status")
              |> th([class: "admin-table-header-cell"], "Actions")
            end)
          end)
          |> tbody([], fn state ->
            Enum.reduce(users, state, fn user, acc_state ->
              render_user_row(acc_state, user)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_user_row(state, user) do
    status_class = if user.status == "active", do: "admin-status-badge admin-status-active", else: "admin-status-badge admin-status-inactive"

    tr(state, [class: "admin-table-row"], fn state ->
      state
      |> td([class: "admin-table-cell"], "##{user.id || ""}")
      |> td([class: "admin-table-cell"], user.name || "")
      |> td([class: "admin-table-cell"], user.email || "")
      |> td([class: "admin-table-cell"], (user.role && String.capitalize(user.role)) || "")
      |> td([class: "admin-table-cell"], fn state ->
        status = (user.status && String.capitalize(user.status)) || "Unknown"
        span(state, [class: status_class], status)
      end)
      |> td([class: "admin-table-cell"], fn state ->
        button(state, [
          class: "admin-button",
          phx_click: "edit_user",
          phx_value_id: user.id
        ], "Edit")
      end)
    end)
  end

  defp render_svg_demo(state, monthly_revenue) do
    # Calculate max revenue for scaling
    max_revenue = case monthly_revenue do
      [] -> 1000
      _ -> Enum.max_by(monthly_revenue, fn {_, rev} -> rev end) |> elem(1) |> max(1000)
    end

    # Generate bar heights (scaled to 0-200 range)
    bars = Enum.with_index(monthly_revenue, fn {_month, revenue}, idx ->
      height = if max_revenue > 0, do: trunc(revenue / max_revenue * 200), else: 0
      x = 70 + idx * 60
      y = 250 - height
      {x, y, height, revenue}
    end)

    # Generate month labels
    month_labels = ["Jan", "Feb", "Mar", "Apr", "May"]

    svg_content = """
    <svg width="400" height="300" viewBox="0 0 400 300" class="admin-svg">
      <rect width="400" height="300" fill="#f9fafb" />
      #{Enum.map_join(0..10, "", fn i ->
        "<line x1=\"50\" y1=\"#{50 + i * 20}\" x2=\"350\" y2=\"#{50 + i * 20}\" stroke=\"#e5e7eb\" stroke-width=\"1\" />"
      end)}
      #{Enum.map_join(bars, "", fn {x, y, height, revenue} ->
        color = case revenue do
          r when r > max_revenue * 0.8 -> "#10b981"
          r when r > max_revenue * 0.5 -> "#3b82f6"
          r when r > max_revenue * 0.3 -> "#f59e0b"
          _ -> "#ef4444"
        end
        "<rect x=\"#{x}\" y=\"#{y}\" width=\"40\" height=\"#{height}\" fill=\"#{color}\" />"
      end)}
      #{Enum.map_join(Enum.with_index(month_labels), "", fn {label, idx} ->
        x = 90 + idx * 60
        "<text x=\"#{x}\" y=\"260\" text-anchor=\"middle\" style=\"font-size: 12px; fill: #6b7280;\">#{label}</text>"
      end)}
      <text x="200" y="30" text-anchor="middle" style="font-size: 14px; font-weight: 600; fill: #1d1d1f;">Monthly Revenue</text>
    </svg>
    """

    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "Statistics Visualization")
      |> div([class: "admin-svg-container"], fn state ->
        Phlex.SGML.append_raw(state, svg_content)
      end)
    end)
  end

  defp render_canvas_demo(state, occupancy_data) do
    # Convert occupancy data to JavaScript array
    occupancy_values = Enum.map(occupancy_data, fn {_date, occupancy} -> occupancy end)
    max_occupancy = case occupancy_values do
      [] -> 10
      _ -> Enum.max(occupancy_values) |> max(10)
    end

    # Generate points for the line chart
    points_js = Enum.with_index(occupancy_values, fn occupancy, idx ->
      x = 50 + idx * 50
      # Scale to 0-150 range (inverted Y)
      y = 150 - trunc(occupancy / max_occupancy * 150)
      "[#{x}, #{y}]"
    end) |> Enum.join(", ")

    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "Interactive Chart (Canvas)")
      |> canvas([
        id: "chartCanvas",
        width: "400",
        height: "200",
        class: "admin-canvas"
      ], "")
      |> script([], Phlex.SGML.safe("""
        (function() {
          const canvas = document.getElementById('chartCanvas');
          if (canvas) {
            const ctx = canvas.getContext('2d');
            const points = [#{points_js}];
            const maxOccupancy = #{max_occupancy};

            ctx.fillStyle = '#f9fafb';
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            if (points.length > 0) {
              ctx.strokeStyle = '#0071e3';
              ctx.lineWidth = 3;
              ctx.beginPath();
              ctx.moveTo(points[0][0], points[0][1]);
              for (var i = 1; i < points.length; i++) {
                ctx.lineTo(points[i][0], points[i][1]);
              }
              ctx.stroke();

              points.forEach(function(point) {
                var x = point[0];
                var y = point[1];
                ctx.fillStyle = '#0071e3';
                ctx.beginPath();
                ctx.arc(x, y, 5, 0, 2 * Math.PI);
                ctx.fill();
              });
            }

            ctx.fillStyle = '#666';
            ctx.font = '12px sans-serif';
            ctx.fillText('Occupancy Trend (Last 7 Days)', 10, 20);
          }
        })();
      """))
    end)
  end

  defp render_settings(state, settings) do
    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "System Settings")
      |> form([class: "admin-form", phx_submit: "save_settings"], fn state ->
        state
        |> div([class: "admin-field"], fn state ->
          state
          |> label([class: "admin-label", for: "site_name"], "Site Name")
          |> input([
            type: "text",
            id: "site_name",
            name: "settings[site_name]",
            value: "#{Map.get(settings, :site_name, "")}",
            class: "admin-input"
          ])
        end)
        |> div([class: "admin-field"], fn state ->
          div(state, [class: "admin-checkbox-container"], fn state ->
            state
            |> input([
              type: "checkbox",
              id: "maintenance_mode",
              name: "settings[maintenance_mode]",
              checked: Map.get(settings, :maintenance_mode, false),
              class: "admin-checkbox"
            ])
            |> label([class: "admin-checkbox-label", for: "maintenance_mode"], "Maintenance Mode")
          end)
        end)
        |> div([class: "admin-field"], fn state ->
          state
          |> label([class: "admin-label", for: "max_reservations"], "Max Reservations")
          |> input([
            type: "number",
            id: "max_reservations",
            name: "settings[max_reservations]",
            value: "#{Map.get(settings, :max_reservations, 100)}",
            class: "admin-input"
          ])
        end)
        |> button([type: "submit", class: "admin-submit"], "Save Settings")
      end)
    end)
  end

  defp render_audio_demo(state) do
    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "Audio Guide")
      |> audio([controls: true, class: "admin-media"], fn state ->
        state
        |> source([src: "/assets/audio/sample.mp3", type: "audio/mpeg"])
        |> source([src: "/assets/audio/sample.ogg", type: "audio/ogg"])
      end)
      |> p([class: "admin-media-text"], "Listen to our hotel welcome message and amenities guide.")
    end)
  end

  defp render_video_demo(state) do
    div(state, [class: "admin-card"], fn state ->
      state
      |> h2([class: "admin-card-title"], "Virtual Tour")
      |> video([
        controls: true,
        class: "admin-media",
        poster: "/assets/images/video-poster.jpg"
      ], fn state ->
        state
        |> source([src: "/assets/video/tour.mp4", type: "video/mp4"])
        |> source([src: "/assets/video/tour.webm", type: "video/webm"])
      end)
      |> p([class: "admin-media-text"], "Take a virtual tour of our facilities.")
    end)
  end
end

defmodule PhoenixDemoWeb.AdminLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.{User, Setting, Reservation}

  @impl true
  def mount(_params, _session, socket) do
    users =
      Repo.all(
        from u in User,
          order_by: [desc: u.inserted_at],
          select: %{
            id: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
            status: u.status
          }
      )

    # Get or create default settings
    settings = case Repo.get(Setting, "default") do
      nil ->
        # Create default settings
        %Setting{}
        |> Ecto.Changeset.change(%{
          id: "default",
          site_name: "DemoApp",
          maintenance_mode: false,
          max_reservations: 100
        })
        |> Repo.insert!()
      setting ->
        setting
    end

    # Get revenue data for last 5 months for charts
    monthly_revenue = get_monthly_revenue()
    occupancy_data = get_occupancy_data()

    {:ok,
     socket
     |> assign(:users, users)
     |> assign(:settings, %{
       site_name: settings.site_name,
       maintenance_mode: settings.maintenance_mode,
       max_reservations: settings.max_reservations
     })
     |> assign(:monthly_revenue, monthly_revenue)
     |> assign(:occupancy_data, occupancy_data)}
  end

  defp get_monthly_revenue do
    # Get revenue for last 5 months from reservations
    today = Date.utc_today()
    months = Enum.map(4..0//-1, fn i -> Date.add(today, -i * 30) end)

    Enum.map(months, fn date ->
      month_start = %{date | day: 1}
      month_end = %{date | day: 28} # Approximate end

      reservations = Repo.all(
        from(r in Reservation,
          where: r.check_in >= ^month_start and r.check_in <= ^month_end,
          select: r.guests
        )
      )

      revenue = Enum.sum(reservations) * 150 # Approximate revenue calculation

      {Date.to_string(month_start), revenue}
    end)
  end

  defp get_occupancy_data do
    # Get occupancy trend for last 7 days
    today = Date.utc_today()
    days = Enum.map(6..0//-1, fn i -> Date.add(today, -i) end)

    Enum.map(days, fn date ->
      occupancy = Repo.aggregate(
        from(r in Reservation,
          where: r.check_in <= ^date and r.check_out >= ^date
        ),
        :count,
        :id
      ) || 0

      {date, occupancy}
    end)
  end

  @impl true
  def handle_event("edit_user", %{"id" => id}, socket) do
    user_id = String.to_integer(id)
    user = Enum.find(socket.assigns.users, fn u -> u.id == user_id end)
    {:noreply, socket |> put_flash(:info, "Editing user: #{user.name} (Demo mode)")}
  end

  @impl true
  def handle_event("save_settings", %{"settings" => settings_params}, socket) do
    # Parse maintenance_mode - can be "true", true, or "on" (from checkbox)
    maintenance_mode =
      case settings_params["maintenance_mode"] do
        "true" -> true
        "on" -> true
        true -> true
        _ -> false
      end

    max_reservations =
      case Integer.parse(settings_params["max_reservations"] || "100") do
        {val, _} -> val
        :error -> 100
      end

    # Get or create settings record
    setting = case Repo.get(Setting, "default") do
      nil ->
        %Setting{id: "default"}
      existing ->
        existing
    end

    # Update settings in database
    setting
    |> Ecto.Changeset.change(%{
      site_name: settings_params["site_name"] || socket.assigns.settings.site_name,
      maintenance_mode: maintenance_mode,
      max_reservations: max_reservations
    })
    |> Repo.insert_or_update!()

    # Reload setting to get updated values
    updated_setting = Repo.get!(Setting, "default")

    updated_settings = %{
      site_name: updated_setting.site_name,
      maintenance_mode: updated_setting.maintenance_mode,
      max_reservations: updated_setting.max_reservations
    }

    {:noreply, socket |> assign(:settings, updated_settings) |> put_flash(:info, "Settings saved successfully!")}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      users: assigns.users,
      settings: assigns.settings,
      monthly_revenue: assigns.monthly_revenue,
      occupancy_data: assigns.occupancy_data
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Admin.render(component_assigns)
    )
  end
end

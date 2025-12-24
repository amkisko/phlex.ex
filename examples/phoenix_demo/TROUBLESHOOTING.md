# Troubleshooting Guide

## Database Seeding

### Automatic Seeding on Startup

The app **automatically seeds** when you run `mix phx.server` if no users exist.

**How it works:**
1. App starts and waits 500ms for database to be ready
2. Checks if any users exist in the database
3. If no users found, automatically runs `priv/repo/seeds.exs`
4. Prints success/failure message

**Check if seeding ran:**
Look for these messages in the console when starting the server:
- `✅ Database seeded successfully on startup!` (seeding happened)
- `ℹ️  Database already has X user(s), skipping seed.` (already seeded)

### Manual Seeding

```bash
# Run seeds directly
mix run priv/repo/seeds.exs

# Full setup (create DB, migrate, seed)
mix ecto.setup

# Reset everything
mix ecto.reset
```

## Database Location

The database file is: `phoenix_demo_dev.db` (in project root)

**If you see an empty database in `config/phoenix_demo_dev.db`:**
```bash
rm config/phoenix_demo_dev.db  # Delete the empty one
```

## Verifying Database Has Data

```bash
# Check record counts
mix run -e "
alias PhoenixDemo.Repo
alias PhoenixDemo.Schemas.{User, Reservation, Customer}
import Ecto.Query
IO.puts(\"Users: #{Repo.one(from u in User, select: count(u.id))}\")
IO.puts(\"Reservations: #{Repo.one(from r in Reservation, select: count(r.id))}\")
IO.puts(\"Customers: #{Repo.one(from c in Customer, select: count(c.id))}\")
"
```

Expected output:
- Users: 4
- Reservations: 3
- Customers: 5

## Forms Not Working

### Check Form Attributes

Phlex converts `phx_submit` (Elixir atom) to `phx-submit` (HTML attribute) automatically.

**In Phlex component:**
```elixir
form([phx_submit: "submit"], fn state ->
  # form content
end)
```

**Renders as:**
```html
<form phx-submit="submit">
  <!-- content -->
</form>
```

### Verify LiveView Handlers

Make sure your LiveView has the matching event handler:

```elixir
def handle_event("submit", %{"reservation" => params}, socket) do
  # Handle form submission
  {:noreply, socket}
end
```

### Common Issues

1. **Form not submitting:**
   - Check browser console for JavaScript errors
   - Verify `phx_submit` attribute is present in rendered HTML
   - Ensure LiveView socket is connected (check for `data-phx-main` in HTML)

2. **Data not saving:**
   - Check database connection
   - Verify `Repo.insert!` or `Repo.insert` is being called
   - Check for validation errors in changeset

3. **No data showing:**
   - Verify database has data (use commands above)
   - Check LiveView `mount/3` is querying database
   - Verify assigns are being passed to Phlex component

## Debugging Steps

1. **Check database exists and has data:**
   ```bash
   ls -lh phoenix_demo_dev.db
   mix run -e "alias PhoenixDemo.Repo; alias PhoenixDemo.Schemas.User; import Ecto.Query; IO.inspect(Repo.one(from u in User, select: count(u.id))))"
   ```

2. **Check if app is using correct database:**
   - Database path: `phoenix_demo_dev.db` (project root)
   - Config: `config/config.exs` → `database: Path.expand("../phoenix_demo_dev.db", __DIR__)`

3. **Verify forms render correctly:**
   - View page source in browser
   - Look for `<form phx-submit="...">` attribute
   - Check for `data-phx-main` attribute on page

4. **Check LiveView connection:**
   - Open browser DevTools → Network tab
   - Look for WebSocket connection to `/live/websocket`
   - Check for any connection errors

5. **Test form submission:**
   - Fill out a form
   - Submit and check browser console for errors
   - Check server logs for `handle_event` calls

## Quick Fixes

### Reset Everything
```bash
mix ecto.reset          # Drops DB, recreates, migrates, seeds
mix phx.server          # Start server
```

### Re-seed Only
```bash
mix run priv/repo/seeds.exs
```

### Check Database Connection
```bash
mix run -e "alias PhoenixDemo.Repo; Repo.query!(\"SELECT 1\") |> IO.inspect()"
```


ExUnit.start()

debug_mode = System.get_env("DEBUG") == "1"

if debug_mode do
  Logger.configure(level: :debug)
else
  Logger.remove_backend(:console)
  Logger.configure(level: :error)
  Application.put_env(:logger, :backends, [])
end

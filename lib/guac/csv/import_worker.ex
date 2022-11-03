defmodule Guac.CSV.ImportWorker do
  @doc """
  Entry point for Task based CSV Import. Uses Task.Supervisor to manage a Task child process
  """
  def perform do
    Task.Supervisor.start_child(Guac.CSV.ImportSupervisor, fn ->
      {:ok, path} = Guac.CSV.Download.source()

      IO.inspect(path)

      File.stream!(path)
      |> Guac.CSV.Importer.run()
    end)

    :ok
  end
end

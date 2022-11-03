defmodule Guac.CSV.Download do
  @source_url "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"

  @doc """
  Downloads the @source_url and initiates a temp file for storage
  """
  def source do
    {:ok, temp_dir} = Briefly.create(directory: true)
    temp_path = Path.join(temp_dir, "guac_download.csv")

    HTTPoison.get(@source_url)
    |> extract_body(temp_path)

    {:ok, temp_path}
  end

  defp extract_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}, temp_path) do
    :ok = File.write!(temp_path, body)
  end

  defp extract_body({:ok, %HTTPoison.Response{status_code: 404}}, _temp_path) do
    {:error, "404 response accessing CSV"}
  end

  defp extract_body({:error, %HTTPoison.Error{reason: reason}}, _temp_path) do
    {:error, "Non-200 response accessing CSV: #{reason}"}
  end
end

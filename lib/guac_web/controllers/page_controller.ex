defmodule GuacWeb.PageController do
  use GuacWeb, :controller

  def index(conn, _params) do
    vendors = Guac.Registrar.get_vendors()

    render(conn, "index.html", vendors: vendors)
  end
end

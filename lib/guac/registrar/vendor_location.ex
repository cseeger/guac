defmodule Guac.Registrar.VendorLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vendor_locations" do
    field :lat_long, Geo.PostGIS.Geometry
    field :location_description, :string
    field :vendor_id, :integer

    timestamps()
  end

  @doc false
  def changeset(vendor_location, attrs) do
    vendor_location
    |> cast(attrs, [:vendor_id, :location_description, :lat_long])
    |> validate_required([:vendor_id, :location_description, :lat_long])
  end
end

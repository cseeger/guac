defmodule Guac.Repo.Migrations.CreateVendorLocations do
  use Ecto.Migration

  def change do
    create table(:vendor_locations) do
      add :vendor_id, references(:vendors)
      add :location_description, :string
      add :lat_long, :geometry

      timestamps()
    end
  end
end

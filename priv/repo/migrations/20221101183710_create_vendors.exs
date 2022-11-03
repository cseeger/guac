defmodule Guac.Repo.Migrations.CreateVendors do
  use Ecto.Migration

  def change do
    create table(:vendors) do
      add :applicant, :string
      add :facility_type, :string
      add :permit, :string
      add :status, :string
      add :food_items, :text
      add :days_hours, :string
      add :expiration_date, :naive_datetime

      timestamps()
    end

    create index(:vendors, :permit)
  end
end

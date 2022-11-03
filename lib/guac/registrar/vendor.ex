defmodule Guac.Registrar.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  alias Guac.Registrar.VendorLocation

  schema "vendors" do
    field :applicant, :string
    field :days_hours, :string
    field :expiration_date, :naive_datetime
    field :facility_type, :string
    field :food_items, :string
    field :permit, :string
    field :status, :string
    has_many :vendor_locations, VendorLocation

    timestamps()
  end

  @doc false
  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [
      :applicant,
      :facility_type,
      :permit,
      :status,
      :food_items,
      :days_hours,
      :expiration_date
    ])
    |> validate_required([
      :applicant,
      :facility_type,
      :permit,
      :status,
      :food_items,
      :expiration_date
    ])
  end
end

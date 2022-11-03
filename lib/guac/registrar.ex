defmodule Guac.Registrar do
  @moduledoc """
  The Registrar context.
  """

  import Ecto.Query, warn: false
  alias Guac.Repo

  alias Guac.Registrar.Vendor

  @doc """
  Gets all vendors and their locations

  ## Examples

      iex> get_vendors()
      [%Vendor{}, ...]

  """
  def get_vendors() do
    Repo.all(Vendor) |> Repo.preload(:vendor_locations)
  end

  @doc """
  Gets a vendor by permit.

  ## Examples

      iex> get_vendor_by_permit("21MFF-00088")
      %Vendor{}

      iex> get_vendor_by_permit("unknown")
      nil

  """
  def get_vendor_by_permit(permit) when is_binary(permit) do
    Repo.get_by(Vendor, permit: permit)
  end

  @doc """
  Creates a Vendor.

  ## Examples

      iex> create_vendor(%{field: value})
      {:ok, %Vendor{}}

      iex> create_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor(attrs \\ %{}) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a VendorLocation.

  ## Examples

      iex> create_vendor_location(vendor, lat, long, location_description)
      {:ok, %VendorLocation{}}

      iex> create_vendor_location(vendor, bad, value, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor_location(vendor, lat, long, location_description)
      when is_float(lat) and is_float(long) do
    # notice the coordinates follow PostGIS "long, lat" format
    lat_long = %Geo.Point{coordinates: {long, lat}, srid: 4326}

    Ecto.build_assoc(vendor, :vendor_locations, %{
      lat_long: lat_long,
      location_description: location_description
    })
    |> Repo.insert()
  end

  def create_vendor_location(_vendor, _lat, _long, _location_description) do
    changeset =
      Ecto.Changeset.add_error(
        %Ecto.Changeset{},
        :lat_long,
        "either lat or long was not float type"
      )

    {:error, changeset}
  end
end

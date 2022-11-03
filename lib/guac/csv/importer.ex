defmodule Guac.CSV.Importer do
  alias NimbleCSV.RFC4180, as: CSV
  alias Guac.Registrar

  @doc """
  Importer parses the given CSV stream into a vendor map of the following shape:

    %{
      location_id: location_id,
      applicant: applicant,
      facility_type: facility_type,
      location_description: location_description,
      permit: permit,
      status: status,
      food_items: food_items,
      latitude: latitude,
      longitude: longitude,
      days_hours: days_hours,
      expiration_date: expiration_date
    }

  Given map stream will be reject the following:
    * Any status but "APPROVED"
    * nil expiration_date
    * nil latitude
    * nil longitude

  """
  def run(stream) do
    # let's delete the existing in lieu of a proper UPSERT
    Guac.Repo.delete_all(Guac.Registrar.VendorLocation)
    Guac.Repo.delete_all(Guac.Registrar.Vendor)

    CSV.parse_stream(stream)
    |> Stream.map(fn [
                       location_id,
                       applicant,
                       facility_type,
                       _cnn,
                       location_description,
                       _address,
                       _blocklot,
                       _block,
                       _lot,
                       permit,
                       status,
                       food_items,
                       _x,
                       _y,
                       latitude,
                       longitude,
                       _schedule,
                       days_hours,
                       _niosent,
                       _approved,
                       _received,
                       _prior_permit,
                       expiration_date,
                       _location,
                       _fire_prevention_districts,
                       _police_districts,
                       _supervisor_districts,
                       _zip_codes,
                       _neighborhoods_old
                     ] ->
      %{
        location_id: location_id,
        applicant: applicant,
        facility_type: facility_type,
        location_description: location_description,
        permit: permit,
        status: status,
        food_items: food_items,
        latitude: latitude,
        longitude: longitude,
        days_hours: days_hours,
        expiration_date: expiration_date
      }
    end)
    |> Stream.reject(&(&1.status != "APPROVED"))
    |> Stream.reject(&(&1.expiration_date == nil))
    |> Stream.reject(&(&1.latitude == nil || &1.latitude == 0))
    |> Stream.reject(&(&1.longitude == nil || &1.longitude == 0))
    |> Stream.reject(&expired_permit?/1)
    |> Stream.each(&process_vendor/1)
    |> Stream.run()
  end

  @doc """
  Returns a boolean indicating whether `expiration_date` has expired or if `expiration_date` is not parseable
  """
  def expired_permit?(%{expiration_date: expiration_date}) do
    case Timex.parse(expiration_date, "%m/%d/%Y %I:%M:%S %p", :strftime) do
      {:ok, parsed} ->
        Timex.before?(parsed, Timex.now())

      _ ->
        true
    end
  end

  @doc """
  Persists `vendor` via Registrar context
  """
  def process_vendor(vendor) do
    # IO.inspect(vendor)

    case Registrar.get_vendor_by_permit(vendor.permit) do
      nil ->
        {:ok, parsed} = Timex.parse(vendor.expiration_date, "%m/%d/%Y %I:%M:%S %p", :strftime)
        vendor = Map.put(vendor, :expiration_date, parsed)
        {:ok, new_vendor} = Registrar.create_vendor(vendor)

        {latitude, ""} = Float.parse(vendor.latitude)
        {longitude, ""} = Float.parse(vendor.longitude)

        {:ok, _vendor_location} =
          Registrar.create_vendor_location(
            new_vendor,
            latitude,
            longitude,
            vendor.location_description
          )

      existing_vendor ->
        {latitude, ""} = Float.parse(vendor.latitude)
        {longitude, ""} = Float.parse(vendor.longitude)

        {:ok, _vendor_location} =
          Registrar.create_vendor_location(
            existing_vendor,
            latitude,
            longitude,
            vendor.location_description
          )
    end
  end
end

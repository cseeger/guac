defmodule Guac.RegistrarFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Guac.Registrar` context.
  """

  def unique_permit, do: "permit-#{System.unique_integer()}"

  def valid_vendor_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      permit: unique_permit(),
      applicant: "Vendor - #{System.unique_integer()}",
      facility_type: "TRUCK",
      status: "APPROVED",
      food_items: "Snacks",
      days_hours: "24/7",
      expiration_date: Timex.shift(Timex.now(), years: 1)
    })
  end

  def vendor_fixture(attrs \\ %{}) do
    {:ok, vendor} =
      attrs
      |> valid_vendor_attributes()
      |> Guac.Registrar.create_vendor()

    vendor
  end

  # def extract_user_token(fun) do
  #   {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
  #   [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
  #   token
  # end
end

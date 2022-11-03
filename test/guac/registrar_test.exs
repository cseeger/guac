defmodule Guac.RegistrarTest do
  use Guac.DataCase

  import Guac.RegistrarFixtures
  alias Guac.Registrar
  alias Guac.Registrar.Vendor

  describe "get_vendor_by_permit/1" do
    test "does not return the vendor if the permit does not exist" do
      refute Registrar.get_vendor_by_permit("unknown")
    end

    test "returns the vendor if the permit exists" do
      %{id: id} = vendor = vendor_fixture()
      assert %Vendor{id: ^id} = Registrar.get_vendor_by_permit(vendor.permit)
    end
  end

  describe "create_vendor/1" do
    test "requires schema fields" do
      {:error, changeset} = Registrar.create_vendor(%{})

      assert %{
               applicant: ["can't be blank"],
               facility_type: ["can't be blank"],
               permit: ["can't be blank"],
               status: ["can't be blank"],
               food_items: ["can't be blank"],
               expiration_date: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "create_vendor_location/4" do
    test "requires float lat long fields" do
      vendor = vendor_fixture()

      assert {:error, _changeset} = Registrar.create_vendor_location(vendor, "lat", "long", nil)
    end

    test "registers valid vendor_location" do
      vendor = vendor_fixture()

      {:ok, _location} =
        Registrar.create_vendor_location(
          vendor,
          37.7620192003565,
          -122.427306422513,
          "A valid location"
        )
    end
  end
end

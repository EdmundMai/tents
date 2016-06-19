class UpsShippingQuote < UpsShipping

  def ship_to
    {
      "CompanyName" => shipping_address.full_name,
      "AttentionName" => shipping_address.full_name,
      "PhoneNumber" => shipping_address.phone_number,
      "Address" => recipient_address
    }
  end

  def recipient_address
    {
      "AddressLine1" => shipping_address.street_address,
      "AddressLine2" => shipping_address.street_address2,
      "City" => shipping_address.city,
      "StateProvinceCode" => shipping_address.state.short_name,
      "CountryCode" => 'US',
      "PostalCode" => shipping_address.zip_code,
      "ResidentialAddress" => nil
    }
  end

  def service
    {
      "Code" => shipping_method.ups_code,
      "Description" => UPS_SERVICE_DESCRIPTIONS[shipping_method.ups_code]
    }
  end
end

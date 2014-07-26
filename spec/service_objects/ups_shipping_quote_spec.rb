require 'spec_helper'

describe UpsShippingQuote do
  it_behaves_like "a ups_shipping"
  
  describe "#shipment_confirm_request" do
    # let(:ups_shipping) { described_class.new }
    let(:shipping_method) { FactoryGirl.build(:ups_ground) }
    let(:shipping_address) { FactoryGirl.build(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "returns a hash with a Request key" do
      ups_shipping.shipment_confirm_request["Request"].should_not be_nil
    end
    
    it "calls the request method" do
      ups_shipping.should_receive(:request)
      ups_shipping.shipment_confirm_request
    end
    
    it "returns a hash with a Shipment key" do
      ups_shipping.shipment_confirm_request["Shipment"].should_not be_nil
    end
    
    it "calls the shipment method" do
      ups_shipping.should_receive(:shipment)
      ups_shipping.shipment_confirm_request
    end
    
    it "returns a hash with a LabelSpecification key" do
      ups_shipping.shipment_confirm_request["LabelSpecification"].should_not be_nil
    end
    
    it "calls the label_specification method" do
      ups_shipping.should_receive(:label_specification)
      ups_shipping.shipment_confirm_request
    end
    
    it "does not raise an error" do
      products = FactoryGirl.create_list(:variant, 2)
      ups_shipping = described_class.new(products: products, shipping_address: shipping_address, shipping_method: shipping_method)
      ups_shipping.shipment_confirm_request.should_not raise_error
    end
    
  end
  
  describe "#shipment" do
    let(:products) { FactoryGirl.create_list(:variant, 4, weight: 10.00) }
    let(:shipping_method) { FactoryGirl.build(:ups_ground) }
    let(:shipping_address) { FactoryGirl.build(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(products: products, shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "returns a hash with a Shipper key" do
      ups_shipping.shipment.find { |k,v| k == 'Shipper' }.should_not be_empty
    end
    
    it "calls the shipper method" do
      ups_shipping.should_receive(:shipper)
      ups_shipping.shipment
    end
    
    it "returns a hash with a ShipTo key" do
      ups_shipping.shipment.find { |k,v| k == 'ShipTo' }.should_not be_empty
    end
    
    it "calls the ship_to method" do
      ups_shipping.should_receive(:ship_to)
      ups_shipping.shipment
    end
    
    it "returns a hash with a Service key" do
      ups_shipping.shipment.find { |k,v| k == 'Service' }.should_not be_empty
    end
    
    it "calls the service method" do
      ups_shipping.should_receive(:service)
      ups_shipping.shipment
    end
    
    it "returns a hash with a PaymentInformation key" do
      ups_shipping.shipment.find { |k,v| k == 'PaymentInformation' }.should_not be_empty
    end
    
    it "calls the payment_information method" do
      ups_shipping.should_receive(:payment_information)
      ups_shipping.shipment
    end
    
    it "returns a hash with a Package key" do
      ups_shipping.shipment.find { |k,v| k == 'Package' }.should_not be_empty
    end
    
    it "calls the package method for every 30 pounds of products" do
      ups_shipping.should_receive(:package).exactly(2).times
      ups_shipping.shipment
    end
  end
  
  describe "#xml_for_initial_request" do
    let(:products) { FactoryGirl.create_list(:variant, 4, weight: 10.00) }
    let(:shipping_method) { FactoryGirl.build(:ups_ground) }
    let(:shipping_address) { FactoryGirl.build(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(products: products, shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "includes a combinaton of access_request and shipment_confirm_request in xml format" do
      desired_xml = ''
      desired_xml << ups_shipping.access_request.to_xml(root: "AccessRequest")
      desired_xml << ups_shipping.shipment_confirm_request.to_xml(root: "ShipmentConfirmRequest")
      ups_shipping.xml_for_initial_request.should include(desired_xml)
    end
  end
  
  describe "#request_shipping_rate" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:shipping_method) { FactoryGirl.build(:ups_ground) }
    let(:shipping_address) { FactoryGirl.build(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(products: products, shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "makes a request to the UPS API using xml_for_initial_request" do
      stub_request(:post, UPS_API['confirm_url']).
          with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => 'zzz', :headers => {})
      ups_shipping.should_receive(:xml_for_initial_request)
      ups_shipping.request_shipping_rate
    end
    
    context "when an error is returned" do
      it "returns an empty string" do
        failure_response = "<ShipmentConfirmResponse><Response><TransactionReference><XpciVersion>1.0001</XpciVersion></TransactionReference><ResponseStatusCode>0</ResponseStatusCode><ResponseStatusDescription>Failure</ResponseStatusDescription><Error><ErrorSeverity>Hard</ErrorSeverity><ErrorCode>10002</ErrorCode><ErrorDescription>The XML document is well formed but the document is not valid</ErrorDescription></Error></Response></ShipmentConfirmResponse>"
        stub_request(:post, UPS_API['confirm_url']).
                 with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
                 to_return(:status => 200, :body => failure_response, :headers => {})
        ups_shipping.request_shipping_rate.should be_blank
      end
    end
    
    context "when an exception is raised" do
      it "returns an empty string" do
        stub_request(:post, UPS_API['confirm_url']).to_timeout
        ups_shipping.request_shipping_rate.should be_blank
      end
    end
    
    context "a response is returned" do
      context "when the response is successful" do
        it "returns a price" do
          success_response = "<ShipmentConfirmResponse><Response><TransactionReference><XpciVersion>1.0001</XpciVersion></TransactionReference><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><ShipmentCharges><TransportationCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>30.97</MonetaryValue></TransportationCharges><ServiceOptionsCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></ServiceOptionsCharges><TotalCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>30.97</MonetaryValue></TotalCharges></ShipmentCharges><BillingWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>23.0</Weight></BillingWeight><ShipmentIdentificationNumber>1ZE435E91297916442</ShipmentIdentificationNumber><ShipmentDigest>secretcode</ShipmentDigest></ShipmentConfirmResponse>"
          stub_request(:post, UPS_API['confirm_url']).
                   with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
                   to_return(:status => 200, :body => success_response, :headers => {})
          ups_shipping.request_shipping_rate.should == 32.97
        end
      end
      context "when there is an error" do
        it "returns an empty string" do
          failed_response = "<ShipmentConfirmResponse><Response><TransactionReference><XpciVersion>1.0001</XpciVersion></TransactionReference><ResponseStatusCode>0</ResponseStatusCode><ResponseStatusDescription>Failure</ResponseStatusDescription><Error><ErrorSeverity>Hard</ErrorSeverity><ErrorCode>120200</ErrorCode><ErrorDescription>Missing or invalid ship to company name</ErrorDescription></Error></Response></ShipmentConfirmResponse>"
          stub_request(:post, UPS_API['confirm_url']).
                   with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
                   to_return(:status => 200, :body => failed_response, :headers => {})
          expect(ups_shipping.request_shipping_rate).to be_blank
        end
      end
    end
  end
  
  describe "#ship_to" do
    let(:shipping_method) { FactoryGirl.create(:ups_ground) }
    let(:shipping_address) { FactoryGirl.create(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "returns a hash with an CompanyName key with value == company" do
      ups_shipping.ship_to["CompanyName"].should == shipping_address.full_name
    end

    
    it "returns a hash with an AttentionName key" do
      ups_shipping.ship_to["AttentionName"].should == shipping_address.full_name
    end
    
    it "returns a hash with an PhoneNumber key" do
      ups_shipping.ship_to["PhoneNumber"].should == shipping_address.phone_number
    end
    
    it "returns a hash with an Address key" do
      ups_shipping.ship_to["Address"].should_not be_blank
    end
    
    it "calls the recipient_address method" do
      ups_shipping.should_receive(:recipient_address)
      ups_shipping.ship_to
    end
  end
  
  describe "#recipient_address" do
    let(:shipping_method) { FactoryGirl.create(:ups_ground) }
    let(:shipping_address) { FactoryGirl.create(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "returns a hash with an AddressLine1 key" do
      ups_shipping.recipient_address["AddressLine1"].should == shipping_address.street_address
    end
    
    it "returns a hash with an AddressLine2 key" do
      ups_shipping.recipient_address["AddressLine2"].should == shipping_address.street_address2
    end
    
    it "returns a hash with a City key" do
      ups_shipping.recipient_address["City"].should == shipping_address.city
    end
    
    it "returns a hash with a StateProvinceCode key" do
      ups_shipping.recipient_address["StateProvinceCode"].should == shipping_address.state.short_name
    end
    
    it "returns a hash with a CountryCode key" do
      ups_shipping.recipient_address["CountryCode"].should == 'US'
    end
    
    it "returns a hash with a PostalCode key" do
      ups_shipping.recipient_address["PostalCode"].should == shipping_address.zip_code
    end
    
    it "returns a hash with a ResidentialAddress key" do
      ups_shipping.recipient_address["ResidentialAddress"].should be_nil
    end
  end
  
  describe "#service" do
    let(:shipping_method) { FactoryGirl.create(:ups_ground) }
    let(:shipping_address) { FactoryGirl.create(:shipping_address) }
    let(:ups_shipping) { UpsShippingQuote.new(shipping_address: shipping_address, shipping_method: shipping_method) }
    
    it "returns a hash with a Code key" do
      ups_shipping.service["Code"].should == shipping_method.ups_code
    end
    
    it "returns a hash with a Description key" do
      ups_shipping.service["Description"].should == UPS_SERVICE_DESCRIPTIONS[shipping_method.ups_code]
    end
  end
end
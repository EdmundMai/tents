shared_examples_for "a ups_shipping" do
  describe "#initialize" do
    it "sets the products" do
      ups_shipping = described_class.new(products: [])
      ups_shipping.products.should match_array []
    end

    it "sets the shipping_address" do
      shipping_address = Address.new
      ups_shipping = described_class.new(shipping_address: shipping_address)
      ups_shipping.shipping_address.should == shipping_address
    end

    it "sets the shipping_method" do
      shipping_method = ShippingMethod.new
      ups_shipping = described_class.new(shipping_method: shipping_method)
      ups_shipping.shipping_method.should == shipping_method
    end
  end

  describe "#access_request" do
    it "returns a hash with an AccessLicenseNumber key" do
      ups_shipping = described_class.new
      ups_shipping.access_request["AccessLicenseNumber"].should == UPS_API["access_key"]
    end
    it "returns a hash with a UserId key" do
      ups_shipping = described_class.new
      ups_shipping.access_request["UserId"].should == UPS_API["user_id"]
    end
    it "returns a hash with a Password key" do
      ups_shipping = described_class.new
      ups_shipping.access_request["Password"].should == UPS_API["password"]
    end
  end

  describe "#request" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    it "calls the transaction_reference method" do
      ups_shipping.should_receive(:transaction_reference)
      ups_shipping.request
    end

    it "returns a hash with a TransactionReference key" do
      ups_shipping.request["TransactionReference"].should_not be_nil
    end

    it "returns a hash with a RequestAction key" do
      ups_shipping.request["RequestAction"].should == "ShipConfirm"
    end

    it "returns a hash with a RequestOption key" do
      ups_shipping.request["RequestOption"].should == "nonvalidate"
    end
  end

  describe "#transaction_reference" do
    let(:ups_shipping) { described_class.new }

    it "returns a hash with a XpciVersion key" do
      ups_shipping.transaction_reference["XpciVersion"].should == "1.0001"
    end
  end



  describe "#shipper" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    it "returns a hash with a Name key" do
      ups_shipping.shipper["Name"].should_not be_nil
    end

    it "returns a hash with a AttentionName key" do
      ups_shipping.shipper["AttentionName"].should_not be_nil
    end

    it "returns a hash with a PhoneNumber key" do
      ups_shipping.shipper["PhoneNumber"].should_not be_nil
    end

    it "returns a hash with a ShipperNumber key" do
      ups_shipping.shipper["ShipperNumber"].should == UPS_API["account_number"]
    end

    it "returns a hash with an Address key" do
      ups_shipping.shipper["Address"].should_not be_nil
    end

    it "calls the address method" do
      ups_shipping.should_receive(:shipper_address)
      ups_shipping.shipper
    end
  end

  describe "#shipper_address" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    it "returns a hash with an AddressLine1 key" do
      ups_shipping.shipper_address["AddressLine1"].should_not be_blank
    end

    it "returns a hash with an City key" do
      ups_shipping.shipper_address["City"].should_not be_blank
    end

    it "returns a hash with an StateProvinceCode key" do
      ups_shipping.shipper_address["StateProvinceCode"].should_not be_blank
    end

    it "returns a hash with an CountryCode key" do
      ups_shipping.shipper_address["CountryCode"].should_not be_blank
    end

    it "returns a hash with an PostalCode key" do
      ups_shipping.shipper_address["PostalCode"].should_not be_blank
    end
  end





  describe "#payment_information" do
    let(:ups_shipping) { described_class.new }

    it "calls the prepaid method" do
      ups_shipping.should_receive(:prepaid)
      ups_shipping.payment_information
    end

    it "returns a hash with a Prepaid key" do
      ups_shipping.payment_information["Prepaid"].should_not be_nil
    end
  end

  describe "#prepaid" do
    let(:ups_shipping) { described_class.new }

    it "calls the bill_shipper method" do
      ups_shipping.should_receive(:bill_shipper)
      ups_shipping.prepaid
    end

    it "returns a hash with a BillShipper key" do
      ups_shipping.prepaid["BillShipper"].should_not be_nil
    end
  end

  describe "#bill_shipper" do
    let(:ups_shipping) { described_class.new }

    it "returns a hash with an AccountNumber key" do
      ups_shipping.bill_shipper['AccountNumber'].should == UPS_API["account_number"]
    end
  end

  describe "#package" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    it "returns a hash with a PackagingType key" do
      ups_shipping.package(products.first)["PackagingType"].should_not be_nil
    end

    it "calls the packaging_type method" do
      ups_shipping.should_receive(:packaging_type)
      ups_shipping.package(products.first)
    end

    it "returns a hash with a PackageWeight key" do
      ups_shipping.package(products.first)["PackageWeight"].should_not be_nil
    end

    it "calls the package_weight method" do
      ups_shipping.should_receive(:package_weight)
      ups_shipping.package(products.first)
    end

  end

  describe "#packaging_type" do
    it "returns a hash with a Code key" do
      ups_shipping = described_class.new
      ups_shipping.packaging_type["Code"].should_not be_blank
    end
  end

  describe "#package_weight" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    it "returns a hash with a Weight key" do
      ups_shipping.package_weight(30)["Weight"].should == 30
    end
  end

  describe "#total_weight_of_products" do
    let(:products) { FactoryGirl.create_list(:variant, 2) }
    let(:ups_shipping) { described_class.new(products: products) }

    context "there are products" do
      it "returns the sum of the products' weights" do
        products = FactoryGirl.create_list(:variant, 2)
        ups_shipping = described_class.new(products: products)
        ups_shipping.total_weight_of_products.should == products.map(&:weight).inject(:+)
      end
    end

    context "there are no products" do
      it "returns the sum of the products' weights" do
        ups_shipping = described_class.new
        ups_shipping.total_weight_of_products.should == 0
      end
    end

  end

  describe "#label_specification" do
    it "returns a hash with a LabelPrintMethod key" do
      ups_shipping = described_class.new
      ups_shipping.label_specification["LabelPrintMethod"].should_not be_nil
    end

    it "calls the label_print_method method" do
      ups_shipping = described_class.new
      ups_shipping.should_receive(:label_print_method)
      ups_shipping.label_specification
    end

    it "returns a hash with a HTTPUserAgent key" do
      ups_shipping = described_class.new
      ups_shipping.label_specification["HTTPUserAgent"].should_not be_blank
    end

    it "returns a hash with a LabelImageFormat key" do
      ups_shipping = described_class.new
      ups_shipping.label_specification["LabelImageFormat"].should_not be_nil
    end

    it "calls the label_image_format method" do
      ups_shipping = described_class.new
      ups_shipping.should_receive(:label_image_format)
      ups_shipping.label_specification
    end
  end

  describe "#label_print_method" do
    it "returns a hash with a Code key" do
      ups_shipping = described_class.new
      ups_shipping.label_print_method["Code"].should_not be_blank
    end
  end

  describe "#label_image_format" do
    it "returns a hash with a Code key" do
      ups_shipping = described_class.new
      ups_shipping.label_image_format["Code"].should_not be_blank
    end
  end





  describe "#package_weights" do
    context "there are no products" do
      it "returns an empty array" do
        ups_shipping = described_class.new
        ups_shipping.package_weights.should match_array []
      end
    end

    context "there are =< 30 lbs of products" do
      it "returns [30]" do
        products = FactoryGirl.create_list(:variant, 3, weight: 10.00)
        ups_shipping = described_class.new(products: products)
        ups_shipping.package_weights.should match_array [30]
      end

      it "returns [25]" do
        products = FactoryGirl.create_list(:variant, 2, weight: 12.50)
        ups_shipping = described_class.new(products: products)
        ups_shipping.package_weights.should match_array [25]
      end
    end

    context "there are > 30 lbs of products " do
      it "returns [30, 6.30]" do
        products = FactoryGirl.create_list(:variant, 3, weight: 12.10)
        ups_shipping = described_class.new(products: products)
        ups_shipping.package_weights.should match_array [30, 6.30]
      end

      it "returns [30, 30, 3.99]" do
        products = FactoryGirl.create_list(:variant, 3, weight: 31.33)
        ups_shipping = described_class.new(products: products)
        ups_shipping.package_weights.should match_array [30, 30, 30, 3.99]
      end
    end

  end

end

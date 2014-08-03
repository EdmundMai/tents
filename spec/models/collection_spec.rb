require 'spec_helper'

describe Collection do
  its(:attributes) { should include "name" }
  its(:attributes) { should include "short_description" }
  its(:attributes) { should include "long_description" }
  its(:attributes) { should include "active" }
  its(:attributes) { should include("slug") }
  
  it { should have_many(:collections_products) }
  it { should have_many(:products).through(:collections_products) }
  
  it { should validate_uniqueness_of(:name) }
  
  describe ".active" do
    it "returns an array of collections with active set to true" do
      coll1 = FactoryGirl.create(:collection, active: true)
      coll2 = FactoryGirl.create(:collection, active: false)
      coll3 = FactoryGirl.create(:collection, active: nil)
      expect(Collection.active).to match_array [coll1]
    end
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shipping_method do
    name "MyString"
    ups_code "MyString"

    factory :ups_ground do
      name "Ground"
      ups_code "03"
    end
  end
end

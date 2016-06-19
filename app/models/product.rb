class Product < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  default_scope { order('name ASC') }

  belongs_to :vendor
  belongs_to :shape
  belongs_to :material
  belongs_to :category

  has_many :products_colors, dependent: :destroy
  has_many :variants, through: :products_colors
  has_many :product_images, through: :products_colors

  has_many :collections_products, dependent: :destroy
  has_many :collections, through: :collections_products

  accepts_nested_attributes_for :products_colors, :allow_destroy => true

  validates_uniqueness_of :name

  def products_colors_attributes=(attrs)
    if self.new_record?
      super(attrs)
    else
      attrs.each do |_, attributes|
        products_color = ProductsColor.where(color_id: attributes[:color_id], product_id: self.id).first_or_initialize
        products_color.update_attributes(attributes)
      end
    end
  end

end

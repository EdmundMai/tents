class Collection < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  default_scope { order('name ASC') }

  has_many :collections_products
  has_many :products, -> { order 'products.name' }, through: :collections_products

  validates_uniqueness_of :name

  scope :active, -> { where(active: true) }
end

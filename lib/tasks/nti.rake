namespace :nti do
  
  desc "Create admin user"
  task(:create_admin_user => :environment) do
    unless User.exists?(email: "admin@admin.com")
      user = User.new
      user.email = "admin@admin.com"
      user.password = "test123"
      user.password_confirmation = "test123"
      user.roles << Role.find_or_create_by(name: 'admin')
      user.save!
    end
  end
  
  task(:create_sizes => :environment) do
    ["XS","S", "M", "L", "XL", "One Size"].each_with_index do |size_name, index|
      size = Size.where(name: size_name).first_or_initialize
      size.sort_order = index
      size.save
    end
  end
  
  task(:create_categories => :environment) do
    ["Eyeglasses", "Sunglasses"].each do |category_name|
      Category.create(name: category_name) unless Category.exists?(name: category_name)
    end
  end
  
  task(:populate_states => :environment) do
    require 'csv'
    CSV.open("#{Rails.root}/state_table.csv").each do |line|
      state = State.new
      state.long_name = line[0]
      state.short_name = line[1]
      unless State.exists?(short_name: state.short_name)
        state.save!
        puts "#{state.long_name} was created."
      end
    end
  end
  
  task(:set_permalinks => :environment) do
    Product.find_each(&:save)
    Collection.find_each(&:save)
  end
  
  task(:google_merchants_feed => :environment) do
    require 'csv'
    CSV.open('products.csv', "wb", {:col_sep => "\t"}) do |csv|
      csv << [
        "id",
        "title",
        "description",
        "product type",
        "link",
        "mobile link",
        "image link",
        "price"
      ]
      
      Product.all.each do |product|
        data = []
        variant = product.variants.last
        data << variant.id
        data << product.name
        data << product.long_description
        data << "play tent"
        data << "www.toddlertents.com/products/#{product.slug}"
        data << "www.toddlertents.com/products/#{product.slug}"
        data << "www.toddlertents.com#{product.product_images.last.image_url}"
        data << variant.price.to_s
        csv << data
      end
      
    end
    
  end
  
  
end
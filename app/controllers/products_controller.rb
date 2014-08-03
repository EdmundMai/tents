class ProductsController < ApplicationController
  
  # def index
  #   @products = Product.where(active: true)
  # end
  
  def show
    @product = Product.friendly.find(params[:id])
  end
  
  
end
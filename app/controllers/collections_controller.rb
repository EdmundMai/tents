class CollectionsController < ApplicationController
  
  def show
    @collection = Collection.friendly.find(params[:id])
  end
  
  def index
    @collections = Collection.active
  end
  
end
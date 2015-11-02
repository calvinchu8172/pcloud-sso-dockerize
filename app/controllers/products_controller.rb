class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:edit, :update]
  respond_to :html, :js

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.create(product_params)
  end

  def edit
    # @product = Product.find(params[:id])
  end

  def update
    @product.update_attributes(product_params)
  end

  def destroy
    
  end

  private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :model_class_name, :asset, :pairing)
    end
end
class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_auth!
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
    error_message(@product)
  end

  def edit
    # @product = Product.find(params[:id])
  end

  def update
    @product.update_attributes(product_params)
    error_message(@product)
  end

  # def destroy
    
  # end

  private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :model_class_name, :asset, :pairing)
    end

    def admin_auth!
      redis_id = Redis::HashKey.new("admin:" + current_user.id.to_s + ":session")

      unless redis_id['name'] == current_user.email
        redirect_to :root
      end
    end

    def error_message(obj)
      if obj.errors.any?
        messages = "<ul>"
        obj.errors.each do |item, error|
          messages += "<li>#{error}</li>"
        end
        messages += "</ul>"
        flash[:error] = messages
      end
    end
end
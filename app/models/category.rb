class Category < ActiveRecord::Base

  has_many :products
  validates :name, uniqueness: true

  def self.collections
    outer_array = []
    categories = Category.all
    categories.each do |category|
      inner_array = []
      inner_array << category.name
      inner_array << category.id
      outer_array << inner_array
    end
    outer_array
  end

end

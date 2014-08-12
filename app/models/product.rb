class Product < ActiveRecord::Base
  # has_many :devices, foreign_key: 'model_name', primary_key: 'model_name'
  has_attached_file :asset, :storage => :s3, styles: {
    thumb: '60x60>',
    square: '200x200#',
    medium: '380x380>'
  }

  validates_attachment_content_type :asset, :content_type => /\Aimage\/.*\Z/
end

class Product < ActiveRecord::Base
  has_many :devices, foreign_key: 'model_name', primary_key: 'model_name'
  has_attached_file :asset, :storage => :s3, styles: {
    thumb: 'x80',
    square: '200x200#',
    medium: 'x85'
  }
  has_attached_file :pairing

  validates_attachment_content_type :asset, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :pairing, :content_type => /\Aimage\/.*\Z/
end

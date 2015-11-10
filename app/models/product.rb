class Product < ActiveRecord::Base
  validates :name, uniqueness: { case_sensitive: false, message: "名稱不可以重複" }
  validates :model_class_name, uniqueness: { case_sensitive: false, message: "型號不可以重複" }

  has_many :devices
  has_attached_file :asset, :storage => :s3, styles: {
    thumb: 'x80',
    square: '200x200#',
    medium: 'x85'
  }
  has_attached_file :pairing, :default_url => "animate_default.gif"

  validates_attachment_content_type :asset, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :pairing, :content_type => /\Aimage\/.*\Z/
end

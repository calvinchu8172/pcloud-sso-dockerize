class Api::Device::V1 < Api::Device
  validates_with MagicNumberValidator
end
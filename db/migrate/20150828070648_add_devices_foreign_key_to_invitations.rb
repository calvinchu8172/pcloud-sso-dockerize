class AddDevicesForeignKeyToInvitations < ActiveRecord::Migration
  def change
    add_foreign_key :invitations, :devices, column: :device_id, name: 'invitations_device_id_fk'
  end
end

class RenameParingSession < ActiveRecord::Migration
  def change
  	rename_table :paring_sessions, :pairing_sessions
  end
end

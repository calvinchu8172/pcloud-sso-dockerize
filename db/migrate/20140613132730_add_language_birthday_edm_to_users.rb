class AddLanguageBirthdayEdmToUsers < ActiveRecord::Migration
  def change
    add_column :users, :language, :string, limit: 30
    add_column :users, :birthday, :datetime
    add_column :users, :edm_accept, :int
  end
end

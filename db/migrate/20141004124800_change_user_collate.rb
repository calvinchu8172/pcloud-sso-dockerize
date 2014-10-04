class ChangeUserCollate < ActiveRecord::Migration
  def change
    execute("ALTER TABLE users MODIFY `first_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
    execute("ALTER TABLE users MODIFY `last_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
    execute("ALTER TABLE users MODIFY `middle_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
    execute("ALTER TABLE users MODIFY `display_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL;")
  end
end

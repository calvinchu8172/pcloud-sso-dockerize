class ChangeColumnCollation < ActiveRecord::Migration
  def up
   execute("ALTER TABLE users MODIFY `email` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL DEFAULT '';")
   execute("ALTER TABLE users MODIFY `encrypted_password` char(60) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL DEFAULT '';")
   execute("ALTER TABLE users MODIFY `reset_password_token` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci;")
   execute("ALTER TABLE users MODIFY `confirmation_token` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci;")
   execute("ALTER TABLE users MODIFY `mobile_number` varchar(40) CHARACTER SET latin1 COLLATE latin1_general_ci;")

   execute("ALTER TABLE devices MODIFY `serial_number` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")
   execute("ALTER TABLE devices MODIFY `mac_address` char(12) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")
   execute("ALTER TABLE devices MODIFY `firmware_version` varchar(120) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")

   execute("ALTER TABLE ddns MODIFY `ip_address` char(8) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")
   execute("ALTER TABLE ddns MODIFY `hostname` varchar(63) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")

   execute("ALTER TABLE domains MODIFY `domain_name` varchar(192) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL;")
  end
end

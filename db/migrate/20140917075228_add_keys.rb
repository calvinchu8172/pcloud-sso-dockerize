class AddKeys < ActiveRecord::Migration
  def up
    add_foreign_key "ddns",         "devices",  name: "ddns_device_id_fk"
    add_foreign_key "ddns",         "domains",  name: "ddns_domain_id_fk"
    add_foreign_key "devices",      "products", name: "devices_product_id_fk"
    add_foreign_key "identities",   "users",    name: "identities_user_id_fk"
    add_foreign_key "pairings",     "devices",  name: "pairings_device_id_fk"
    add_foreign_key "pairings",     "users",    name: "pairings_user_id_fk"
  end
  def down
    remove_foreign_key "ddns",       name: "ddns_device_id_fk"
    remove_foreign_key "ddns",       name: "ddns_domain_id_fk"
    remove_foreign_key "devices",    name: "devices_product_id_fk"
    remove_foreign_key "identities", name: "identities_user_id_fk"
    remove_foreign_key "pairings",   name: "pairings_device_id_fk"
    remove_foreign_key "pairings",   name: "pairings_user_id_fk"
  end
end

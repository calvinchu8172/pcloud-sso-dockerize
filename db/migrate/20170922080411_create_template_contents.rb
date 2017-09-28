class CreateTemplateContents < ActiveRecord::Migration
  def change
    create_table :template_contents do |t|
      t.integer   :template_id, index: true, null: false
      t.string    :locale, index: true
      t.string    :title
      t.text      :content

      t.timestamps null: false
    end
  end
end

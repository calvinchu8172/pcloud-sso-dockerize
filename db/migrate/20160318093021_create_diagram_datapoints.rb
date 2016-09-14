class CreateDiagramDatapoints < ActiveRecord::Migration
  def change
    create_table :diagram_datapoints do |t|
      t.string :type
      t.string :value

      t.timestamps null: false
    end
  end
end

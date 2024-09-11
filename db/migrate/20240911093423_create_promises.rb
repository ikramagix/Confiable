class CreatePromises < ActiveRecord::Migration[7.2]
  def change
    create_table :promises do |t|
      t.string :title
      t.text :description
      t.references :politician, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end

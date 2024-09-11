class CreateActions < ActiveRecord::Migration[7.2]
  def change
    create_table :actions do |t|
      t.references :promise, null: false, foreign_key: true
      t.text :description
      t.timestamp :date

      t.timestamps
    end
  end
end

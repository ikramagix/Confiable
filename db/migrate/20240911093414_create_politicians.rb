class CreatePoliticians < ActiveRecord::Migration[7.2]
  def change
    create_table :politicians do |t|
      t.string :name
      t.string :party
      t.string :position

      t.timestamps
    end
  end
end

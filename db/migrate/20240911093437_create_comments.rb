class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :promise, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end

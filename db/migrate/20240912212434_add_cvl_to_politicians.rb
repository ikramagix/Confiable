class AddCvlToPoliticians < ActiveRecord::Migration[7.2]
  def change
    add_column :politicians, :cvl, :string
  end
end

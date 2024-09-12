class AddTypeMandatAndDepartementToPoliticians < ActiveRecord::Migration[7.2]
  def change
    add_column :politicians, :type_duty, :string
    add_column :politicians, :department, :string
  end
end

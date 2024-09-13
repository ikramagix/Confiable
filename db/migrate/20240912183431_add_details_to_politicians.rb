class AddDetailsToPoliticians < ActiveRecord::Migration[7.2]
  def change
    add_column :politicians, :last_name, :string
    add_column :politicians, :first_name, :string
    add_column :politicians, :birth_date, :date
    add_column :politicians, :role, :string
    add_column :politicians, :organization, :string
    add_column :politicians, :publication_date, :date
    add_column :politicians, :location, :string
    add_column :politicians, :declaration_link, :string
    add_column :politicians, :assets, :text
    add_column :politicians, :additional_info, :text
  end
end

class AddCityToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :city, :string
  end
end

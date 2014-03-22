class CreateP42RevenueGroups < ActiveRecord::Migration
  def change
    create_table :p42_revenue_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end

class AddPriceTypeSponsorToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string
    add_column :projects, :sponsor, :integer
    add_column :projects, :payment_price, :decimal
  end
end

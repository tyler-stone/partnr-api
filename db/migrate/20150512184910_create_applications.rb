class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.column :status, :integer, default: 0
      t.belongs_to :user, :integer, index: true
      t.belongs_to :role, :integer, index: true

      t.timestamps
    end

    add_column :roles, :application_id, :integer
  end
end

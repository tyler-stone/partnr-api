class AddProjectToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :project_id, :integer
  end
end

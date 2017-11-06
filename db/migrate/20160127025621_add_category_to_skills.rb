class AddCategoryToSkills < ActiveRecord::Migration
  def change
    add_reference :skills, :category, index: true, foreign_key: true
  end
end

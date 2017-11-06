class ChangeProjectOwnerAndCreatorToNotNull < ActiveRecord::Migration
  def change
    change_column_null :projects, :owner, false
    change_column_null :projects, :creator, false
  end
end

class AddBmarkToPost < ActiveRecord::Migration
  def change
    add_reference :posts, :bmark, index: true, foreign_key: true
  end
end

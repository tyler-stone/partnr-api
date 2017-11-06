class AddAttachmentCoverPhotoToProjects < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.attachment :cover_photo
    end
  end

  def self.down
    remove_attachment :projects, :cover_photo
  end
end

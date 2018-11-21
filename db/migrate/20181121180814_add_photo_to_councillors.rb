class AddPhotoToCouncillors < ActiveRecord::Migration[5.2]
  def change
    add_column :councillors, :photo, :string
  end
end

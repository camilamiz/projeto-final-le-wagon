class AddPartyToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :party, :string
  end
end

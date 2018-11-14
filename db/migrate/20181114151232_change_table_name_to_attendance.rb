class ChangeTableNameToAttendance < ActiveRecord::Migration[5.2]
  def change
    rename_table :presences, :attendances
  end
end

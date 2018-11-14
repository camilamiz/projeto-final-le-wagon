class AddAttendanceDate < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :att_date, :date
  end
end

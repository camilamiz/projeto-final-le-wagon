class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.references :councillor, foreign_key: true
      t.boolean :present
      t.timestamps
    end
  end
end

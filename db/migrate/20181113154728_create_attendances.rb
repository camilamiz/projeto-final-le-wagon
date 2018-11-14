class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.references :councillor, foreign_key: true
<<<<<<< HEAD
=======
      t.date :date
>>>>>>> 618553f1712f68dd9efbc0dc656db057c5750c66
      t.boolean :present

      t.timestamps
    end
  end
end

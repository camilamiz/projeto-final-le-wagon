class CreateCouncillors < ActiveRecord::Migration[5.2]
  def change
    create_table :councillors do |t|
      t.string :name
      t.string :party

      t.timestamps
    end
  end
end

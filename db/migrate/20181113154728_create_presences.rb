class CreatePresences < ActiveRecord::Migration[5.2]
  def change
    create_table :presences do |t|
      t.references :councillor, foreign_key: true
      t.references :session, foreign_key: true
      t.boolean :present

      t.timestamps
    end
  end
end

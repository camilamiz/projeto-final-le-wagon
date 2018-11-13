class CreateVereadors < ActiveRecord::Migration[5.2]
  def change
    create_table :vereadors do |t|
      t.string :nome
      t.string :partido

      t.timestamps
    end
  end
end

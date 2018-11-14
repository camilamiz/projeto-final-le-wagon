class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :chave
      t.string :tipo
      t.integer :numero
      t.integer :ano
      t.string :ementa

      t.timestamps
    end
  end
end

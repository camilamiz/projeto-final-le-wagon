class CreateVotings < ActiveRecord::Migration[5.2]
  def change
    create_table :votings do |t|
      t.references :project, foreign_key: true
      t.references :councillor, foreign_key: true
      t.boolean :vote

      t.timestamps
    end
  end
end

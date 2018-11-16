class AddColumnsToVotings < ActiveRecord::Migration[5.2]
  def change
    add_column :votings, :tipo, :string
    add_column :votings, :materia, :string
    add_column :votings, :ementa, :string
    add_column :votings, :rodape, :string
  end
end

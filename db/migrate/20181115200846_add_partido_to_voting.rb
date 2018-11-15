class AddPartidoToVoting < ActiveRecord::Migration[5.2]
  def change
    add_column :votings, :partido, :string
  end
end

class AddChaveToVotings < ActiveRecord::Migration[5.2]
  def change
    add_column :votings, :chave, :integer
  end
end

class AddResultToVotings < ActiveRecord::Migration[5.2]
  def change
    add_column :votings, :resultado, :string
  end
end

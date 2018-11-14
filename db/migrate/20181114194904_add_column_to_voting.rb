class AddColumnToVoting < ActiveRecord::Migration[5.2]
  def change
    add_column :votings, :sessao, :string
    add_column :votings, :vote_date, :date
  end
end

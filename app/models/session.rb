class Session < ApplicationRecord
  has_many :votings
  has_many :presences
  has_many :projects, through: :votings
  has_many :councillors, through: :presences
end

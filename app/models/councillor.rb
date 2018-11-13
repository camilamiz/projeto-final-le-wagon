class Councillor < ApplicationRecord
  has_many :votings
  has_many :presences
  has_many :autorships
  has_many :projects, through: :autorships
end

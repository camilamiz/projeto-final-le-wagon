class Councillor < ApplicationRecord
  has_many :votings
  has_many :presences
  has_many :authorships
  has_many :projects, through: :authorships
end

class Councillor < ApplicationRecord
  has_many :votings
  has_many :attendances
  has_many :authorships
  has_many :projects, through: :authorships
end

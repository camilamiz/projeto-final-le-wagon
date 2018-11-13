class Project < ApplicationRecord
  has_many :votings
  has_many :autorships
  has_many :councillors, through: :autorships
end

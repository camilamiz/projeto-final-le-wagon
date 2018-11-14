class Project < ApplicationRecord
  has_many :votings
  has_many :authorships
  has_many :councillors, through: :authorships
end

class Session < ApplicationRecord
  has_many :votings
  has_many :attendances
  has_many :projects, through: :votings
  has_many :councillors, through: :attendances
end

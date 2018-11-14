class Authorship < ApplicationRecord
  belongs_to :project
  belongs_to :councillor
  validates :project, uniqueness: { scope: :councillor }
end

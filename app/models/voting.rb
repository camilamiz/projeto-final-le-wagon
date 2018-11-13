class Voting < ApplicationRecord
  belongs_to :project
  belongs_to :councillor
  belongs_to :session
  validates :session, uniqueness: { scope: [:project, :councillor] }
end

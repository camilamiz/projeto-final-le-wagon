class Voting < ApplicationRecord
  belongs_to :project
  belongs_to :councillor
end

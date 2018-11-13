class Presence < ApplicationRecord
  belongs_to :councillor
  belongs_to :session
  validates :session, uniqueness: { scope: :councillor }
end

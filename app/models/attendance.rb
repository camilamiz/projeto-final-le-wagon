class Attendance < ApplicationRecord
  belongs_to :councillor
  belongs_to :session
  validates :session, uniqueness: { scope: :councillor }
end


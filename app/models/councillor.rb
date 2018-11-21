class Councillor < ApplicationRecord
  has_many :votings
  has_many :attendances
  has_many :authorships
  has_many :projects, through: :authorships

  def self.councillors_project_status(councillor_id)
  sql = "
    SELECT * FROM projects p
    JOIN authorships a ON a.project_id = p.id
    JOIN councillors c ON c.id = a.councillor_id
    WHERE councillor_id = \'#{councillor_id}\' "

  query = ActiveRecord::Base.connection.execute(sql)

  return query

  # .group_by { |c| c['ano'] }.map do |councillor_array|
  #   councillor_array[1].map do |result|
  #     [councillor_array[0], result['status']]
    # end
  # end

  end

end


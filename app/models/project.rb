class Project < ApplicationRecord
  has_many :votings
  has_many :authorships
  has_many :councillors, through: :authorships

  def self.councillors_names(ano, tipo)
    sql = "
      SELECT c.* FROM projects p
      JOIN authorships a ON a.project_id = p.id
      JOIN councillors c ON c.id = a.councillor_id
      WHERE tipo = \'#{tipo}\' AND ano = #{ano}
    "

    query = ActiveRecord::Base.connection.execute(sql)

    query.group_by { |c| c['name'] }.map do |councillor_array|
      #
      # councillor_array[0] its the name of the councillor
      # councillor_array[1] its his projects tipo
      #
      [
        councillor_array[0], councillor_array[1].count
      ]
    end


  end
end

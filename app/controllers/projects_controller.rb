class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    @parties_projects2016 = count_projects(2016)
    @parties_projects2017 = count_projects(2017)
    @project_list = ["PL", "PDL", "RDS", "IND", "SUB"]
    @status_list = ["Em Tramitação", "Vetado", "Aprovado", "Promulgado", "Encerrado por Ilegalidade", "Retirado pelo autor"]
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def count_projects(year)
    parties = Attendance.where("att_date > ?", Date.parse("01 Jan 2017")).map { |att| att[:party] }.uniq
    hash = {}
    parties.each do |partido|
      hash[partido] = Project.where("ano > ?", year).joins(:councillors).where(councillors: { party: partido }).count
    end
    return hash
  end
end

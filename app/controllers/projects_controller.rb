class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    @parties_projects = count_projects
    @project_list = ["PL", "PDL", "RDS", "IND", "SUB"]
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def count_projects
    parties = Attendance.where("att_date > ?", Date.parse("01 Jan 2017")).map { |att| att[:party] }.uniq
    hash = {}
    parties.each do |partido|
      hash[partido] = Project.where("ano > ?", 2016).joins(:councillors).where(councillors: { party: partido }).count
    end
    return hash
  end
end

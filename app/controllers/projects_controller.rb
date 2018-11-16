class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    @parties_projects = count_projects
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def count_projects
    hash = {}
    Project.where("ano > ?", 2016).each do |project|
      proj_parties = project.authorships.map { |p| Councillor.find(p[:councillor_id]).party }.uniq
      proj_parties.each do |partido|
        if hash.key?(partido) ? hash[partido] += 1 : hash[partido] = 1
      end
    end
  end
end

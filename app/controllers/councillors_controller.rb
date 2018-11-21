class CouncillorsController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    @councillors = Councillor.joins(:votings).where("vote_date > ?", Date.parse("01 Jan 2017")).uniq
    general_total_days = Attendance.where("att_date > ?", Date.parse("01 Jan 2017")).count.to_f
    general_present_days = Attendance.where("att_date > ? AND present = ?", Date.parse("01 Jan 2017"), true).count.to_f
    @general_presence = (general_present_days / general_total_days * 100).floor(2)
    @party_attendances = count_attendances
    @parties_projects2016 = count_projects(2016)
    @parties_projects2017 = count_projects(2017)
  end

  def show
    @councillors = index
    @councillor = Councillor.find(params[:id])
    @total_days = @councillor.attendances.where("att_date > ?", Date.parse("01 Jan 2017")).count.to_f
    @present_days = @councillor.attendances.where("att_date > ? AND present = ?", Date.parse("01 Jan 2017"), true).count.to_f
    @presence = (@present_days / @total_days * 100).floor(2)
    @ranking_tipos = rank_types(@councillor)
    @tipo_list_show = @councillor_projects.map { |p|
      p[:tipo]
    }.uniq
    @projects = Project.joins(:authorships).where(authorships: {councillor: @councillor} )
    @status_list = ["Em Tramitação", "Vetado", "Aprovado", "Promulgado", "Encerrado por Ilegalidade", "Retirado pelo autor"]
  end


  private

  def count_attendances
    hash = {}
    attendances = Attendance.where("att_date > ?", Date.parse("01 Jan 2017"))
    att_parties = attendances.map { |att| att[:party] }.uniq
    att_parties.each do |partido|
      hash[partido] = (attendances.where(party: partido, present: true).count.to_f /
                        attendances.where(party: partido).count.to_f * 100).floor(2)
    end
    return hash
  end

  def rank_types(councillor)
    @councillor_projects = Project.where.not(tipo: "SUB").joins(:authorships).where(authorships: { councillor: councillor })
  end

  def count_projects(year)
    parties = Attendance.where("att_date > ?", Date.parse("01 Jan 2017")).map { |att| att[:party] }.uniq
    hash = {}
    parties.each do |partido|
      hash[partido] = Project.where("ano > ?", year).joins(:councillors).where(councillors: { party: partido }).count
    end
    return hash
  end
end

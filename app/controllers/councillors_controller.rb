class CouncillorsController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    @councillors = Councillor.joins(:votings).where("vote_date > ?", Date.parse("01 Jan 2017")).uniq
    general_total_days = Attendance.where("att_date > ?", Date.parse("01 Jan 2017")).count.to_f
    general_present_days = Attendance.where("att_date > ? AND present = ?", Date.parse("01 Jan 2017"), true).count.to_f
    @general_presence = (general_present_days / general_total_days * 100).floor(2)
    @party_attendances = count_attendances
  end

  def show
    @councillors = index
    @councillor = Councillor.find(params[:id])
    @total_days = @councillor.attendances.where("att_date > ?", Date.parse("01 Jan 2017")).count.to_f
    @present_days = @councillor.attendances.where("att_date > ? AND present = ?", Date.parse("01 Jan 2017"), true).count.to_f
    @presence = (@present_days / @total_days * 100).floor(2)
    @ranking_tipos = rank_types(@councillor)
  end

  # def profile_image
  # end

  private

  # def parsing
  #   name = 'chocolate'
  #   url = "http://www.letscookfrench.com/recipes/find-recipe.aspx?s=#{ingredient}"

  #   html_file = open(url).read
  #   html_doc = Nokogiri::HTML(html_file)

  #   html_doc.search('.m_titre_resultat a').each do |element|
  #     puts element.text.strip
  #     puts element.attribute('href').value
  #   end
  # end

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
    projects = Project.where.not(tipo: "SUB").joins(:authorships).where(authorships: { councillor: councillor })
    result = {}
    projects.map { |proj| proj[:ano] }.uniq.each do |ano|
      hash = {}
      projects.map { |proj| proj[:tipo] }.uniq.each do |type|
        hash[type] = projects.where("tipo = ? AND ano = ?", type, ano).count
      end
      result[ano] = hash.sort_by { |_key, value| value }.reverse.to_h
    end
    return result
  end
end

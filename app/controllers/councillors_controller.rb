class CouncillorsController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    @councillors = []
    Voting.where("vote_date > ?", Date.parse("01 Jan 2017")).each do |voting|
      councillor = voting.councillor
      @councillors << councillor if @councillors.include?(councillor) == false
    end
    return @councillors
  end

  def show
    @councillor = Councillor.find(params[:id])
    @total_days = @councillor.attendances.where("att_date > ?", Date.parse("01 Jan 2017")).count.to_f
    @present_days = @councillor.attendances.where("att_date > ? AND present = ?", Date.parse("01 Jan 2017"), true).count.to_f
    @presence = (@present_days / @total_days * 100).floor(2)
  end

  def profile_image
  end

  private

  def parsing
    name = 'chocolate'
    url = "http://www.letscookfrench.com/recipes/find-recipe.aspx?s=#{ingredient}"

    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    html_doc.search('.m_titre_resultat a').each do |element|
      puts element.text.strip
      puts element.attribute('href').value
    end
  end
end

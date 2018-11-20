class Voting < ApplicationRecord
  belongs_to :project
  belongs_to :councillor


# Votings with date range
  def self.session_grouped(date_range = {})
    date_range = {
      start_date: order(:vote_date).pluck(:vote_date).first,
      end_date: order(:vote_date).pluck(:vote_date).last
    } if date_range.empty?

    where("vote_date > ? AND vote_date < ?", date_range[:start_date], date_range[:end_date])
      .group(:sessao).count
  end

# Votings with date range
  def self.grouped_by_year(date_range = {})
    date_range = {
      start_date: order(:vote_date).pluck(:vote_date).first,
      end_date: order(:vote_date).pluck(:vote_date).last
    } if date_range.empty?

    where("vote_date > ? AND vote_date < ?", date_range[:start_date], date_range[:end_date])
      .group_by_month(:vote_date, format: "%b %Y").count
  end

# Votings by project_id
  def self.project_grouped
    group(:project_id).count
  end
end

class VotingsController < ApplicationController
  def index
    # query = params[:query]

    @votings = Voting.all
  end
end

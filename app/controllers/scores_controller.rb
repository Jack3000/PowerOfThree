class ScoresController < ApplicationController

  def create
    Score.create!(score_params)
    render nothing: true
  end

  def score_params
    params.require(:score).permit(:user_id, :score, :board_size)
  end
end
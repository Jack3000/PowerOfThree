class ScoresController < ApplicationController
	after_action :score_limiter, only: :create

  def index
    size = params[:board_size].to_i
    size.in?(1..12) ? b_size = size : b_size = 6
    if current_user == nil
      @scores = Score.where(user_id: nil, board_size: b_size).order("score DESC").limit(25)
    else
      @scores = Score.where(user_id: current_user.id, board_size: b_size).order("score DESC").limit(25)
    end
  end

  def all
    size = params[:board_size].to_i
    size.in?(1..12) ? b_size = size : b_size = 6
    @scores = Score.where(board_size: b_size).order("score DESC").limit(25)
  end

  def create
    Score.create!(score_params)
    render nothing: true
  end

  def destroy_user_scores
    @scores = Score.where(user_id: current_user.id)
    @scores.each do |score|
      score.destroy
    end
    flash[:notice] = "Your scores have been successfully deleted."
    redirect_to user_path(current_user)
  end

  def top_score
    if params[:user] == "all_users"
      score = Score.top_score(params[:board_size], "all")
    else
      score = Score.top_score(params[:board_size], params[:user])
    end
    respond_to do |format|
      format.json { render json: {score: score} }
    end
  end

  def score_params
    params.require(:score).permit(:user_id, :score, :board_size)
  end

  def score_limiter
  	score = Score.order("created_at DESC").limit(1).first
  	scores = Score.where(user_id: (score.user_id), board_size: (score.board_size))
  	scores.order("score ASC").limit(1).first.destroy if scores.length > 25
  end
end
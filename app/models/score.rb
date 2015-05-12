class Score < ActiveRecord::Base

	def self.top_score(board_size, user)
		where(board_size: board_size, user_id: user).order('score DESC').limit(1).first.try(:score) || 0
	end
end
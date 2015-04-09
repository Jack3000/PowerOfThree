class Score < ActiveRecord::Base

	def self.top_score(board_size)
		where(board_size: board_size).order('score DESC').limit(1).first.try(:score) || 0
	end
end
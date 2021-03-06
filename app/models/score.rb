class Score < ActiveRecord::Base

	def self.top_score(board_size, user)
		if user == "all"
			where(board_size: board_size).order('score DESC').limit(1).first.try(:score) || 0
		else
			where(board_size: board_size, user_id: user).order('score DESC').limit(1).first.try(:score) || 0
		end
	end

	def self.get_rankings(user)
		ranks = []
		board_sizes = Array.new(12) { |i| i + 1 }
		board_sizes.each do |board_size|
			if Score.top_score(board_size, user) != 0
				higher_scorers = []
				x = "not banana"
				until x == "banana" do
					top = Score.where(board_size: board_size).where.not(user_id: higher_scorers).order('score DESC').first
					if higher_scorers.exclude?(nil)
						alt_top = Score.where(board_size: board_size, user_id: nil).order("score DESC").first
						top = alt_top if alt_top.score > top.score
					end
					if top.user_id == user
						x = "banana"
						ranks.push("You are the #{(higher_scorers.length + 1).ordinalize} highest scoring player on board size #{board_size}!")
					else
						higher_scorers.push(top.user_id)
					end
				end
			end
		end
		if ranks.length == 0
			ranks.push("You have no rankings yet.")
		end
		ranks
	end
end
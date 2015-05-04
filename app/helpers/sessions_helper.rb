module SessionsHelper

	def log_in(user)
		user.remember_me!
		cookies[:remember_token] = {value: user.remember_token, expires: 10.years.from_now}
		self.current_user = user
	end

	def log_out
		cookies.delete(:remember_token)
    self.current_user = nil
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		@currnet_user ||= token_remembered_user
	end

	def token_remembered_user
		remember_token = cookies[:remember_token]
		User.find_by_remember_token(remember_token) unless remember_token == nil
	end

end
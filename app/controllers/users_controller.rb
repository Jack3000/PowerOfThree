class UsersController < ApplicationController
	require 'digest'

	def new
		render 'login'
	end

	def show # temporary so I can look at the 'create' page without creating new user.
		@user = User.first
		render 'create'
	end

	def create
		byebug
		@user = User.new(user_params)
		if @user.save
			log_in(@user)
			render 'create'
		else
			render 'login'
		end
	end

	def user_params
		u_params = params.require(:user).permit(:name, :email)
		if params[:user][:password].length == 0
			u_params[:password] = nil
			u_params[:password_confirmation] = nil
		else
			salt = SecureRandom.base64(32)
			encrypted_password = Digest::SHA256.hexdigest params[:user][:password] + salt
			confirm_pass_encrypt = Digest::SHA256.hexdigest params[:user][:password_confirmation] + salt
			u_params[:password] = encrypted_password
			u_params[:password_confirmation] = confirm_pass_encrypt
			u_params[:salt] = salt
		end
		return u_params
	end
end
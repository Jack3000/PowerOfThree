class UsersController < ApplicationController
	require 'digest'
	before_action :set_user_and_name, only: :destroy
	before_action :disable_log_box, only: [:show, :destroy]

	def new
		render 'login'
	end

	def show
		@user = current_user
		render 'show'
	end

	def create
		@user = User.new(user_params)
		if @user.save
			log_in(@user)
			render 'create'
		else
			render 'login'
		end
	end

	def destroy
		@user.destroy
		render 'deleted'
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

	def disable_log_box
		@disable_log_box = true
	end

	def set_user_and_name
		@user = current_user
		@user_name = @user.name
	end
end
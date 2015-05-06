class SessionsController < ApplicationController

  def create
    user = User.where("lower(name) = ?", params[:session][:name_or_email].downcase).first
    user = User.where("lower(email) = ?", params[:session][:name_or_email].downcase).first if user == nil
    if user
      pass_checks = user.password_check(params[:session][:password])
    end
    if user == nil || pass_checks == false
      flash[:error] = "Invalid name/password combination."
      redirect_to(:back)
    else
      log_in(user)
      render 'create'
    end
  end
  
  def destroy
    log_out
    redirect_to root_path
  end

end
class WelcomeController < ApplicationController

  def index
    render 'index'
  end

  def instructions
  	render '_instructions', layout: false
  end
end
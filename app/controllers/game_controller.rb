class GameController < ApplicationController

  def index
    render 'index'
  end

  def instructions
  	render '_instructions', layout: false
  end

  def extreme
  	render 'extreme', layout: false
  end
end
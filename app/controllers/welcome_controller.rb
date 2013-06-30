class WelcomeController < ApplicationController
  def index
  end

  def main
    render :layout => false
  end
end

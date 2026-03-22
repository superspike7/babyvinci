class HomeController < ApplicationController
  def show
    redirect_to new_baby_path unless current_baby
  end
end

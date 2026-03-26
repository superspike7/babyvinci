class ApplicationController < ActionController::Base
  include Authentication

  private

    def ensure_baby
      redirect_to root_path unless current_baby
    end
end

class MoreController < ApplicationController
  def show
    redirect_to new_baby_path and return unless current_baby

    @active_invite = current_baby.baby_invites.active.order(created_at: :desc).first
  end
end

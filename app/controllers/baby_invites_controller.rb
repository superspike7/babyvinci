class BabyInvitesController < ApplicationController
  before_action :require_current_baby

  def new
    @baby_invite = current_baby.baby_invites.new
    @active_invite = current_baby.baby_invites.active.order(created_at: :desc).first
  end

  def create
    if current_baby.parent_limit_reached?
      redirect_to today_path, alert: "Both parent seats are already in use." and return
    end

    if (active_invite = current_baby.baby_invites.active.order(created_at: :desc).first)
      redirect_to baby_invite_path(active_invite), notice: "An invite is already ready to share." and return
    end

    @baby_invite = current_baby.baby_invites.new(baby_invite_params)
    @baby_invite.invited_by_user = current_user

    if @baby_invite.save
      redirect_to baby_invite_path(@baby_invite), notice: "Invite ready to share."
    else
      @active_invite = nil
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @baby_invite = current_baby.baby_invites.find(params[:id])
  end

  private
    def baby_invite_params
      params.require(:baby_invite).permit(:email)
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end
end

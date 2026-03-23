class InvitesController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    @invite = BabyInvite.find_by(token: params[:token])

    return render_unavailable unless @invite&.active?

    @acceptance_user = User.new(email: @invite.email)
  end

  private
    def render_unavailable
      render "invites/unavailable", status: :gone
    end
end

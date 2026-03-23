class InviteAcceptancesController < ApplicationController
  allow_unauthenticated_access only: :create

  def create
    @invite = BabyInvite.find_by(token: params[:token])
    return render_unavailable unless @invite&.active?

    if authenticated?
      accept_existing_user
    else
      accept_new_user
    end
  end

  private
    def accept_existing_user
      unless @invite.matching_email?(current_user.email)
        @acceptance_user = current_user
        @error_message = "Use the invited email address to join this baby log."
        render "invites/show", status: :unprocessable_entity
        return
      end

      @invite.accept!(current_user)
      current_user.update_columns(invited_at: current_user.invited_at || @invite.created_at, accepted_at: Time.current)
      redirect_to today_path, notice: "You're in. #{@invite.baby.first_name}'s shared log is ready."
    rescue ActiveRecord::RecordInvalid
      render_unavailable
    end

    def accept_new_user
      @acceptance_user = User.new(acceptance_params)

      unless @invite.matching_email?(@acceptance_user.email)
        @error_message = "Use the invited email address to join this baby log."
        render "invites/show", status: :unprocessable_entity
        return
      end

      ActiveRecord::Base.transaction do
        @acceptance_user.invited_at ||= @invite.created_at
        @acceptance_user.accepted_at = Time.current
        @acceptance_user.save!
        @invite.accept!(@acceptance_user)
        start_new_session_for(@acceptance_user)
      end

      redirect_to today_path, notice: "You're in. #{@invite.baby.first_name}'s shared log is ready."
    rescue ActiveRecord::RecordInvalid
      render "invites/show", status: :unprocessable_entity
    end

    def acceptance_params
      params.fetch(:acceptance, {}).permit(:name, :email, :password, :password_confirmation)
    end

    def render_unavailable
      render "invites/unavailable", status: :gone
    end
end

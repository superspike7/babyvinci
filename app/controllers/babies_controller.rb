class BabiesController < ApplicationController
  before_action :redirect_if_baby_exists, only: %i[new create]

  def new
    @baby = Baby.new(birth_at: Time.zone.now.change(sec: 0))
  end

  def create
    @baby = Baby.new(first_name: baby_params[:first_name], birth_at: birth_at_from_params)

    if @baby.valid?
      BabyCreator.create!(user: current_user, first_name: @baby.first_name, birth_at: @baby.birth_at)
      redirect_to today_path, notice: "Baby profile ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def baby_params
      params.require(:baby).permit(:first_name, :birth_date, :birth_time)
    end

    def birth_at_from_params
      return if baby_params[:birth_date].blank? || baby_params[:birth_time].blank?

      Time.zone.parse("#{baby_params[:birth_date]} #{baby_params[:birth_time]}")
    end

    def redirect_if_baby_exists
      redirect_to today_path if current_baby.present?
    end
end

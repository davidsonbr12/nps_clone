class CheersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Show cheers received by the current user
    @cheers = current_user.received_cheers.order(created_at: :desc)
    # Show cheers sent by the current user
    @sent_cheers = current_user.sent_cheers.order(created_at: :desc)
  end

  def new
    @cheer = Cheer.new
    # Get all other users for the recipient dropdown, excluding the current user
    @recipients = User.where.not(id: current_user.id).employee
  end

  def create
    @cheer = Cheer.new(cheer_params)
    @cheer.sender = current_user

    if @cheer.save
      redirect_to cheers_path, notice: "Cheer sent successfully!"
    else
      @recipients = User.where.not(id: current_user.id).employee
      render :new, status: :unprocessable_entity
    end
  end

    private
    def cheer_params
      # Only allow content and recipient_id to be passed through the form
      params.require(:cheer).permit(:content, :recipient_id)

    end
end
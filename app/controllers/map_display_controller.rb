class MapDisplayController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized

  def index
    @user = current_user
    authorize :map_display
  end
end

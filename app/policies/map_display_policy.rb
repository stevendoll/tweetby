class MapDisplayPolicy < Struct.new(:user, :map_display)
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @map_display = model
  end

  def index?
    true
  end

end

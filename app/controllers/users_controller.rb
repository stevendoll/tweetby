class UsersController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized
  before_action :set_user, only: [:show, :edit, :update, :finish_signup, :destroy]


  def index
    @users = User.all
    authorize User
  end

  def show
    authorize @user
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  # # PATCH/PUT /users/:id.:format
  # def update
  #   authorize @user
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       sign_in(@user == current_user ? @user : current_user, :bypass => true)
  #       format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    authorize @user, :update?
    if request.patch? && params[:user] && params[:user][:email]
      if @user.update_attributes(signup_params)
        @user.skip_reconfirmation!
        #sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    # else
    #   render action: 'finish_signup', notice: 'not updated.'
    end
  end


  def destroy
    authorize @user
    @user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def secure_params
    params.require(:user).permit(:role)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    accessible = [ :role, :name, :email, :authentication_token, :current_password, :first_name, :last_name, :phone, :description, :avatar, :invitation_code, :tag_list ] # extend with your own params
    accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end

  def signup_params
    params.require(:user).permit(:email)
  end


end

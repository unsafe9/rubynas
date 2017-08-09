class UsersController < ApplicationController
  before_action :require_existing_user, :only => [:edit, :update, :destroy]

  def index
  end

  def show
    if User.find_by_name params[:name]
      render "index"
    else
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  def new
  end

  def create
    @user = User.new(permitted_params_user)
    respond_to do |format|
      if @user.save
        sign_in @user
        format.html { redirect_to @user }
        #format.js {}
        #format.json { render :show, status: :created, location: @user }
      else
        format.html { render "index" }
        format.json { render json: @user.errors, status: :unprocessable_entity, content_type: "application/json" }
      end
    end
  end

  # Note: @user is set in require_existing_user
  def edit
  end

  # Note: @user is set in require_existing_user
  def update
    # if @user.update_attributes(permitted_params.user.merge({ :password_required => false }))
    #   redirect_to edit_user_url(@user), :notice => t(:your_changes_were_saved)
    # else
    #   render :action => 'edit'
    # end
  end

  # Note: @user is set in require_existing_user
  def destroy
    @user.destroy
    redirect_to "index"
  end


  private

  def permitted_params_user
    return params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def require_existing_user
    if current_user.admin? && params[:name] != current_user.name.to_s
      @user = User.find_by_name params[:name]
    else
      @user = current_user
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to users_url, :alert => t(:user_already_deleted)
  end
end
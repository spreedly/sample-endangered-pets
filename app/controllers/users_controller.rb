class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.password_required = true

    return render(:action => :new) unless @user.save
    
    self.current_user = @user
    flash[:notice] = "Thanks for signing up!  You've been logged in."
    
    redirect_to root_url
  end

end

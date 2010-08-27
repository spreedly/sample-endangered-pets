class SessionsController < ApplicationController

  before_filter :login_required, :only => [ :destroy ]
  
  def new
  end
  
  def create
    logout_keeping_session!
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      redirect_back_or_default(root_url)
    else
      flash.now[:error]= "Invalid email or password."
      render(:action => :new)
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(login_url)
  end
  
end

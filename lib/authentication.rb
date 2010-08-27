module Authentication
  
  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= login_from_session unless @current_user == false
  end

  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end

  def authorized?(action = action_name, resource = nil)
    logged_in?
  end

  def login_required
    return true if authorized?
    access_denied 
  end

  def access_denied
    store_location
    flash[:warning] = "You must be logged in to access that part of the site."
    redirect_to login_url
  end

  def store_location(location=nil)
    session[:return_to] = location ? location : request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def self.included(base)
    base.send :helper_method, :current_user, :logged_in? 
  end

  def login_from_session
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def logout_keeping_session!
    @current_user = false 
    session[:user_id] = nil
  end

  def logout_killing_session!
    logout_keeping_session!
  end

end

class ApplicationController < ActionController::Base
  
  def authenticate_user!
    redirect_to new_sessions_path unless current_user
  end

  private
  
  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end
end

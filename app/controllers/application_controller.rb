class ApplicationController < ActionController::Base
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def authenticate_user!
    redirect_to new_sessions_path unless current_user
  end

  private
  
  def record_not_found
    flash[:alert] = 'The record you were looking for could not be found.'
    redirect_to root_path
  end

  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end
end

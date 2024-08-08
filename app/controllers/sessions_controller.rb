# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'basic'

  def new; end

  def create
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      session[:current_user_id] = @user.id
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:current_user_id)
    # Clear the memoized current user
    @_current_user = nil
    redirect_to root_path
  end
end

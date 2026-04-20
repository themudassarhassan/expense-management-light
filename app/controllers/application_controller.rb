# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    flash[:alert] = 'The record you were looking for could not be found.'
    redirect_to root_path
  end
end

# frozen_string_literal: true

class ProfilesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    permitted = normalized_profile_params or return

    if @user.update(permitted)
      redirect_to edit_profile_path, notice: 'Your profile has been updated.' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :current_password)
  end

  def normalized_profile_params
    permitted = user_params
    current_password_attempt = permitted.delete(:current_password)
    permitted = without_new_password_fields(permitted) if permitted[:password].blank?
    return permitted unless changing_password?(permitted)

    return permitted if @user.authenticate(current_password_attempt)

    reject_password_change!(permitted)
    nil
  end

  def without_new_password_fields(permitted)
    permitted.except(:password, :password_confirmation)
  end

  def changing_password?(permitted)
    permitted[:password].present?
  end

  def reject_password_change!(permitted)
    @user.assign_attributes(permitted.except(:password, :password_confirmation))
    @user.errors.add(:current_password, 'is incorrect')
    render :edit, status: :unprocessable_entity
  end
end

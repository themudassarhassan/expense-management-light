# frozen_string_literal: true

class HomeController < ApplicationController
  helper DashboardHelper

  def index
    @dashboard = Dashboard::Snapshot.new(Current.user)
  end
end

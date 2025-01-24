class Auth::EventsController < ApplicationController
  def index
    @auth_events = Current.user.auth_events.order(created_at: :desc)
  end
end

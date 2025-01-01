class EventsController < ApplicationController
  # allow_unauthenticated_access only: %i[ index ]

  def index
    render :index
  end

  def new
    @event = Event.new
  end

end

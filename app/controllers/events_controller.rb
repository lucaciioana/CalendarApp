class EventsController < ApplicationController
  # allow_unauthenticated_access only: %i[ index ]

  def index
    @events = Event.all
    @event_types = EventType.created_by(Current.user)
    render :index
  end

  def new
    @event = Event.new({ repeatable: false })
  end

  def create
    puts "????"
    puts "params: #{params}"
  end

end

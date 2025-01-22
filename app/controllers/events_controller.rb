class EventsController < ApplicationController
  # allow_unauthenticated_access only: %i[ index ]

  def index
    @events = Event.all
    @event_types = EventType.created_by(Current.user)
    render :index
  end

  def new
    @event = Event.new()
  end

  def create
    @event = Event.new(event_params)
    respond_to do |format|
      if @event.save
        format.html { redirect_to root_path, notice: 'Event added successfully' }
        format.json { render root_path, status: :created, location: @event}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity}
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :event_type, :date)
  end
end

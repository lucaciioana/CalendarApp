class EventsController < ApplicationController
  # allow_unauthenticated_access only: %i[ index ]
  before_action :set_model, only: [:show, :update]

  def index
    ensure_locals
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
        format.json { render root_path, status: :created, location: @event }
        format.turbo_stream do
          ensure_locals
          flash.now[:notice] = "Event: #{@event.event_type.name} added successfully!"
          render turbo_stream: [
            turbo_stream.update(
              'calendar',
              partial: 'events/calendar', locals: { events: EventType.includes(:events).created_by(Current.user) }
            ),
            turbo_stream.remove('modal-content'),
            turbo_stream.prepend("flash", **toast(type: :success))
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to ensure_proper_redirect, notice: 'Event updated successfully' }
        format.json { render :index, status: :created, location: @event }
        format.turbo_stream do
          ensure_locals
          flash.now[:notice] = "Event: #{@event.event_type.name} updated successfully!"
          render turbo_stream: [
            turbo_stream.update(
              'calendar',
              partial: 'events/calendar', locals: { events: EventType.includes(:events).created_by(Current.user) }
            ),
            turbo_stream.remove('modal-content'),
            turbo_stream.prepend("flash", **toast(type: :success))
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      begin
        events = Event.includes(:event_type)
                      .created_by(Current.user)
                      .where(id: event_destroy_params[:ids])
        deleted_events = events.collect { |event| event.event_type.name }
        events.delete_all
      rescue Exception => e
        format.html { render events_path, status: :unprocessable_entity }
      end
      format.turbo_stream do
        ensure_locals
        flash.now[:notice] = "Event: #{deleted_events.join(', ')} removed successfully"
        render turbo_stream: [
          turbo_stream.update(
            'calendar',
            partial: 'events/calendar', locals: { events: EventType.includes(:events).created_by(Current.user) }
          ),
          turbo_stream.remove('modal-content'),
          turbo_stream.prepend("flash", **toast(type: :success))
        ]
        # redirect_to root_path
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:description, :event_type_id, :date).merge({ creator: Current.user })
  end

  def event_destroy_params
    params.permit(:_method, :authenticity_token, ids: [])
  end

  def ensure_locals
    start_date = params.fetch(:start_date, Date.current).to_date
    @event_types = EventType.created_by(Current.user)
    @events = Event.includes(:event_type)
                   .where(event_type: @event_types, date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
    @summary = @events
                 .where(date: start_date.beginning_of_month..start_date.end_of_month)
                 .joins(:event_type)
                 .select('event_type_id, event_types.name as type_name, event_types.price as price, COUNT(events.id) as count, SUM(event_types.price) as total_price')
                 .group('event_types.id')
  end

  def set_model
    id = params.fetch(:id)
    @event = Event.find_by(id:)
  end
end

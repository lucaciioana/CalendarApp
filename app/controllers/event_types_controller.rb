class EventTypesController < ApplicationController
  include ApplicationHelper

  def index
    grid_payload
  end

  def new
    @event_type = EventType.new
  end

  def create
    @event_type = EventType.new(event_type_params)
    respond_to do |format|
      if @event_type.save
        grid_payload
        format.html { redirect_to ensure_proper_redirect, notice: 'Event type added successfully' }
        format.json { render :index, status: :created, location: @event_type }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              'content',
              **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
            ),
            turbo_stream.remove('modal')
          ]
        end

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

  end

  def destroy
    begin
      EventType.created_by(Current.user)
               .where(id: event_type_destroy_params[:ids])
               .delete_all
    rescue Error => e
      puts "e: #{e}"
      render event_types_path, status: :unprocessable_entity
    end
    redirect_to event_types_path, notice: 'Event types removed successfully'
  end

  private

  def ensure_proper_redirect
    request.referer.include?("event_types") ? event_types_path : root_path
  end

  def event_type_params
    params.require(:event_type).permit(:name, :price).merge({ creator: Current.user })
  end

  def event_type_destroy_params
    params.permit(ids: [])
  end

  def grid_payload
    @data = EventType.created_by(Current.user)
    @headers = ['name', 'price']
    @title = 'Event Types'
    @desc = 'Event type - used when adding events'
    @model = EventType
  end

end

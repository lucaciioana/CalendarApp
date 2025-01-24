class EventTypesController < ApplicationController
  include ApplicationHelper
  before_action :set_model, only: [:show, :update]

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
          flash.now[:notice] = "Event Type: #{@event_type.name} added successfully!"
          render turbo_stream: [
            turbo_stream.update(
              'content',
              **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
            ),
            turbo_stream.remove('modal-content'),
            turbo_stream.prepend("flash", **toast(type: :success))
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

  def update
    respond_to do |format|
      if @event_type.update(event_type_params)
        grid_payload
        flash.now[:notice] = "Event Type: #{@event_type.name} updated successfully!"
        format.html { redirect_to ensure_proper_redirect }
        format.json { render :index, status: :created, location: @event_type }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              'content',
              **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
            ),
            turbo_stream.remove('modal-content'),
            turbo_stream.prepend("flash", **toast(type: :success))
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ids_to_delete = event_type_destroy_params[:ids]
    errors = []
    results = EventType.is_deletable(ids_to_delete)
    results.map { |res| errors.push(res.name) if res.count != 0 }

    # some of the ids are not deletable
    unless errors.blank?
      respond_to do |format|
        flash.now[:notice] = "Unable to delete #{errors.join(', ')} as they're used in events. Please delete the events first."
        format.turbo_stream do
          grid_payload
          render turbo_stream: [
            turbo_stream.update(
              'content',
              **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
            ),
            turbo_stream.prepend("flash", **toast(auto_hide: true, type: :error))
          ]
        end
      end
      return
    end

    # proceed with the deletion as expected
    respond_to do |format|
      begin
        records = EventType.created_by(Current.user)
                           .where(id: ids_to_delete)
        records.each do |record|
          record.delete
        end
      rescue Exception => e
        flash.now[:notice] = e.message
        # render event_types_path, status: :unprocessable_entity
        format.turbo_stream do
          grid_payload
          render turbo_stream: [
            turbo_stream.update(
              'content',
              **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
            ),
            turbo_stream.prepend("flash", **toast(type: :success))
          ]
        end
      end
      flash.now[:notice] = "Event types: #{results.collect(&:name).join(', ')} removed successfully"
      format.html { redirect_to event_types_path }
      format.turbo_stream do
        grid_payload
        render turbo_stream: [
          turbo_stream.update(
            'content',
            **grid(title: @title, desc: @desc, headers: @headers, data: @data, model: @model)
          ),
          turbo_stream.prepend("flash", **toast(type: :success))
        ]
      end
    end
  end

  private

  def ensure_proper_redirect
    request.referer.include?("event_types") ? event_types_path : root_path
  end

  def event_type_params
    params.require(:event_type).permit(:name, :price).merge({ creator: Current.user })
  end

  def event_type_destroy_params
    params.permit(:_method, :authenticity_token, ids: [])
  end

  def grid_payload
    @data = EventType.created_by(Current.user)
    @headers = ['name', 'price']
    @title = 'Event Types'
    @desc = 'Event type - used when adding events'
    @model = EventType
  end

  def set_model
    id = params.fetch(:id)
    @event_type = EventType.find_by(id:)
  end
end
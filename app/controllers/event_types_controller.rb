class EventTypesController < ApplicationController
  def index
    @data = EventType.created_by(Current.user)
    @headers = ['name', 'price']
  end

  def new
    @event_type = EventType.new
  end

  def create
    @event_type = EventType.new(event_type_params)
    respond_to do |format|
      if @event_type.save
        format.html { redirect_to event_types_path, notice: 'Event type added successfully' }
        format.json { render :index, status: :created, location: @event_type}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity}
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

  def event_type_params
    params.require(:event_type).permit(:name, :price).merge({ creator: Current.user })
  end

  def event_type_destroy_params
    params.permit(ids: [])
  end

end

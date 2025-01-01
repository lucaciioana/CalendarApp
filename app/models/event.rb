class Event < ApplicationRecord
  belongs_to :creator
  belongs_to :event_type
end

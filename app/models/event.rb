class Event < ApplicationRecord
  belongs_to :creator, class_name: :User
  belongs_to :event_type

  validates :name, presence: true
  validates :event_type, presence: true
  validates :date, presence: true
end

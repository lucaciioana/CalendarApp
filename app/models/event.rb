class Event < ApplicationRecord
  belongs_to :creator, class_name: :User
  belongs_to :event_type

  validates :event_type_id, presence: true
  validates :date, presence: true

  scope :created_by, ->(creator) { where(creator: creator) }

  def start_time
    self.date
  end

  def end_time
    self.date
  end
end

class EventType < ApplicationRecord
  belongs_to :creator, class_name: :User
  validates :name, presence: true
  scope :created_by, ->(creator) { where(creator: creator) }
end

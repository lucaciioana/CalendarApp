class EventType < ApplicationRecord
  belongs_to :creator, class_name: :User
  has_many :events, dependent: :restrict_with_exception
  validates :name, presence: true
  scope :created_by, ->(creator) { where(creator: creator) }

  def self.is_deletable(ids)
    result = EventType.where(id: ids)
                      .left_joins(:events)
                      .group(:id)
                      .select('event_types.id as `id`, event_types.name as `name`, COUNT(events.id) AS `count`')
  end
end

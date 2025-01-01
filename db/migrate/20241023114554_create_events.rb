class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.references :event_type, null: false, index: true, foreign_key: true
      t.datetime :start
      t.integer :duration
      t.datetime :end
      t.references :creator, null: false, index: true, foreign_key: {to_table: :users}
      # t.json :excluded_dates
      t.json :schedule
      t.boolean :is_deleted
      t.timestamps
    end
  end
end

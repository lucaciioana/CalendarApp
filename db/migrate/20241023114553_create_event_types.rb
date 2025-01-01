class CreateEventTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :event_types do |t|
      t.string :name
      t.references :creator, null: false, index: true, foreign_key: { to_table: :users }
      t.boolean :is_deleted

      t.timestamps
    end
  end
end

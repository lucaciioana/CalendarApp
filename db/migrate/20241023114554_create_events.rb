class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :event_type, null: false, index: true, foreign_key: true
      t.string :description
      t.datetime :date
      t.references :creator, null: false, index: true, foreign_key: {to_table: :users}
      t.timestamps
    end
  end
end

class CreateAuthEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :auth_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
  end
end

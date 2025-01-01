class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.references :owner, index: true, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    create_join_table :users, :groups do |t|
      t.string :custom_name
      t.index :user_id
      t.index :group_id
    end
  end
end

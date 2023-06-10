class CreateRelationships < ActiveRecord::Migration[7.0]
  def up
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.integer :is_deleted

      t.timestamps null: false
    end

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end

  def down
    drop_table :attendances
  end
end

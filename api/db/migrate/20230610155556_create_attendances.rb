class CreateAttendances < ActiveRecord::Migration[7.0]
  def up
    create_table :attendances do |t|
      t.integer  :user_id
      t.integer  :status, null: false
      t.datetime :record_time, null: false

      t.timestamps null: false
    end

    add_index :attendances, [:user_id, :status, :created_at]
    add_index :attendances, :created_at
  end

  def down
    drop_table :attendances
  end
end

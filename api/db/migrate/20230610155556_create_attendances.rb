class CreateAttendances < ActiveRecord::Migration[7.0]
  def up
    create_table :attendances do |t|
      t.integer  :user_id
      t.datetime :clock_in, null: true
      t.datetime :clock_out, null: true

      t.timestamps null: false
    end

    add_index :attendances, [:user_id, :clock_in]
    add_index :attendances, [:user_id, :clock_out]
    add_index :attendances, :created_at
  end

  def down
    drop_table :attendances
  end
end

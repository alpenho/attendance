class CreateAttendances < ActiveRecord::Migration[7.0]
  def up
    create_table :attendances do |t|
      t.integer  :user_id
      t.datetime :check_in, null: true
      t.datetime :check_out, null: true

      t.timestamps null: false
    end

    add_index :attendances, [:user_id, :check_in]
    add_index :attendances, [:user_id, :check_out]
    add_index :attendances, :created_at
  end

  def down
    drop_table :attendances
  end
end

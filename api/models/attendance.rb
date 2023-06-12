class Attendance < ActiveRecord::Base
  enum status: [ :clock_in, :clock_out ]

  has_one :user

  validates :user_id, presence: true
  validates :status, presence: true
end
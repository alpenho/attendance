class Attendance < ActiveRecord::Base
  has_one :user

  validates :user_id, presence: true
end
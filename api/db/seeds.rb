require 'json'

def create_users!
  file = File.open('db/seeds/users.json')
  data_users = JSON.load(file)

  data_users.each do |data_user|
    new_user = ::User.new(
      name: data_user['name']
    )
    new_user.save!
  end
end

def create_attendances!
  file = File.open('db/seeds/attendances.json')
  data_attendances = JSON.load(file)
  users = ::User.all

  users.each do |user|
    data_attendances.each do |data_attendance|
      new_attendance = ::Attendance.new(
        user_id: user.id,
        clock_in: DateTime.strptime(data_attendance['clock_in'], '%Y-%m-%d %H:%M %z'),
        clock_out: DateTime.strptime(data_attendance['clock_out'], '%Y-%m-%d %H:%M %z')
      )
      new_attendance.save!
    end
  end
end

create_users!
create_attendances!

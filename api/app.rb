require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/param'
require 'rack/contrib'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:development)

Dir['models/*.rb'].each { |file| require_relative file }

class AttendanceApiApp < Sinatra::Base
  use Rack::JSONBodyParser
  helpers Sinatra::Param

  get '/' do
    'It Works!'
  end

  get '/users' do
    users = ::User.all
    json users
  end

  post '/clock-in' do
    param :user_id, Integer, required: true
    param :clock_in, DateTime, required: true

    user = ::User.find(params[:user_id])
    if user.blank?
      halt 422, 'user_id incorrect'
    end

    new_attendance = Attendance.new(
      user_id: params[:user_id],
      status: 0,
      record_time: params[:clock_in]
    )
    ActiveRecord::Base.transaction do
      new_attendance.save!
    end

    json user.attendances.clock_in.order(created_at: :desc)
  end

  post '/users/:id/follow' do
    param :other_user_id, Integer, required: true

    current_user = ::User.find_by(id: params[:id])
    other_user = ::User.find_by(id: params[:other_user_id])

    if other_user.blank? || current_user.blank?
      halt 422, 'user_id incorrect'
    end

    ActiveRecord::Base.transaction do
      begin
        current_user.follow!(other_user)
      rescue => error
        halt 500, error.message
      end
    end

    json current_user.following
  end

  post '/users/:id/unfollow' do
    param :other_user_id, Integer, required: true

    current_user = ::User.find_by(id: params[:id])
    other_user = ::User.find_by(id: params[:other_user_id])

    if other_user.blank? || current_user.blank?
      halt 422, 'user_id incorrect'
    end

    ActiveRecord::Base.transaction do
      current_user.unfollow!(other_user)
    end

    json current_user.following
  end

  get '/users/:id/sleep-record' do
    current_user = ::User.find_by(id: params[:id])

    if current_user.blank?
      halt 422, 'user_id incorrect'
    end

    list_user_ids = current_user.following.map(&:id)
    list_user_ids << current_user.id

    current_time = Time.now.utc
    week_ago = (current_time - 1.week) + 1.day
    attendances = ::Attendance.where(user_id: list_user_ids).where("record_time <= ? AND record_time >= ?", current_time, week_ago)

    sleep_records = []
    while week_ago <= current_time
      user_attendances = attendances.select { |attendance|
        attendance.record_time >= week_ago.beginning_of_day && attendance.record_time <= week_ago.end_of_day
      }.group_by { |attendance|
        attendance.user_id
      }

      results = user_attendances.map do |k, v|
        {
          user_id: k,
          sleep_record: (((v.last.record_time - v.first.record_time) / 60) / 60),
          created_at: v.last.created_at
        }
      end

      sleep_records << results
      week_ago += 1.day
    end

    json sleep_records.reject(&:empty?).flatten.sort_by { |record| record[:created_at] }
  end
end
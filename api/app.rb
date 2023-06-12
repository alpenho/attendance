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
end
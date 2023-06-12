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
end
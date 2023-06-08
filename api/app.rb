require 'sinatra'

class AttendanceApiApp < Sinatra::Base
  get '/' do
    'It Works!'
  end
end
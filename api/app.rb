require 'sinatra'
require 'sinatra/activerecord'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:development)

Dir['models/*.rb'].each { |file| require_relative file }

class AttendanceApiApp < Sinatra::Base
  get '/' do
    'It Works!'
  end
end
require 'sinatra'
require 'bundler/setup'
require 'net/http'
require 'json'

# initializes cache to avoid repeated queries for same requests
$cache = {}

get '/' do
  'hello world'
end

get '/:test' do
  content_type :json
  if params['test']
    t = params['test']
      return {:test => t}.to_json
  end
end
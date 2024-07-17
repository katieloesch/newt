require 'sinatra'
require 'bundler/setup'
require 'net/http'
require 'json'
require 'httparty'
require 'uri'


set :port, 9292

# initializes cache to avoid repeated queries for same requests
$cache = {}

# URL of the DBpedia SPARQL endpoint
ENDPOINT_URL = 'http://dbpedia.org/sparql'


def make_query(sparql_query, limit = 10)

  # max number of HTTP redirects = 10 -> avoid infinite loop
  raise 'Too many HTTP redirects' if limit == 0
  
  # create uri object from endpoint url
  uri = URI(ENDPOINT_URL)

  # define query parameters
  query_params = { query: sparql_query, format: 'json' }
  
  # use HTTParty gem to make a GET request to the URI with the query parameters, save response to variable
  response = HTTParty.get(uri, query: query_params)

  # conditionally handle the HTTP response based on the status code
  case response.code
    # 200 status code -> ok -> parse resoibse body from JSON to a ruby hash and return it
  when 200
    JSON.parse(response.body)
    # 301 | 302 | 307 status codes -> redirection -> get new location from header and print warning, call make_query recursively until limit reached
  when 301, 302, 307
    location = response.headers['location']
    warn "redirected to #{location}"
    make_query(sparql_query, limit - 1)
  else
    puts "HTTP Request failed (#{response.code} #{response.message})"
    {}
  end
  # for any other status codes print error message, return empty hash
rescue JSON::ParserError => e
  puts "JSON Parsing Error: #{e.message}"
  {}
end

# test if make_query is working
test_query = <<-SPARQL
SELECT ?film WHERE {
  ?film rdf:type dbo:Film .
  ?film dbo:starring dbr:Sigourney_Weaver .
}
SPARQL

test_result = make_query(test_query)
p JSON.pretty_generate(test_result)


get '/' do
  'hello world'
end
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


# GET: films by actor
def get_films_by_actor(actor_name)
  sparql_query = <<-SPARQL
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbpprop: <http://dbpedia.org/property/>
    SELECT ?filmName WHERE {
      ?film dbpprop:starring ?actor .
      ?actor rdfs:label "#{actor_name}"@en .
      ?film rdfs:label ?filmName .
      FILTER (lang(?filmName) = "en")
    }
  SPARQL

  result = make_query(sparql_query)
  result['results']['bindings'].map { |binding| binding['filmName']['value'] }
end

# GET: actors by film
def get_actors_by_film(film_name)
  sparql_query = <<-SPARQL
  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX dbo: <http://dbpedia.org/ontology/>
  SELECT DISTINCT ?actorName WHERE {
    ?film rdfs:label ?filmLabel .
    ?film dbo:starring ?actor .
    ?actor rdfs:label ?actorName .
    FILTER (lang(?actorName) = "en" && contains(?filmLabel, "#{film_name}"))
  }
  SPARQL

  result = make_query(sparql_query)
  actor_names = result['results']['bindings'].map { |binding| binding['actorName']['value'] }
  unique_actor_names = actor_names.uniq
  unique_actor_names
end

#route for the root URL
get '/' do
  content_type :json
  if params['actor']
    actor = params['actor']
    if $cache[actor]
      return $cache[actor].to_json
    else
      films = get_films_by_actor(actor)
      $cache[actor] = { films: films }
      return { films: films }.to_json
    end
  elsif params['film']
    film = params['film']
    if $cache[film]
      return $cache[film].to_json
    else
      actors = get_actors_by_film(film)
      $cache[film] = { actors: actors }
      return { actors: actors }.to_json
    end
  else
    status 400
    return { error: 'Please provide either an actor or a film parameter' }.to_json
  end
end
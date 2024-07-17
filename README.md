# Newt

## Overview

1. [Description](#description)
2. [Installation](#installation)
3. [Technologies Used](#technologies)
4. [Deliverables](#deliverables)
5. [Planning/Build Process](#planning)
6. [Challenges](#challenges)

---

## <a name="description"></a> 1. Description

The goal of this project is to build a web service that returns JSON information about films and their casts using Ruby-based tools. I chose to use Sinatra for this application. It allows users to query the DBpedia dataset to retrieve films by a specific actor or actors in a specific film. The application uses SPARQL queries to interact with the DBpedia SPARQL endpoint and caches the results to improve performance.

## <a name="installation"></a> 3. Installation

```zsh
bundle install
```

- to start the application, run:

```zsh
ruby app.rb
```

- The application will start on port 9292.

## <a name="technologies"></a> 4. Technologies Used

### Additional tools used:

- Git / GitHub
  - used for version control
  - https://git-scm.com/
  - https://github.com/
- Visual Studio Code (VSCode)
  - code editor used
  - https://code.visualstudio.com/
- Google Chrome browser
  - used for launching the website and displaying the application Google Chrome
- Google Chrome Developer Tools: For troubleshooting and debugging
  - https://www.google.com/intl/en_uk/chrome/

### Resources and tutorials:

- medium:
  - https://medium.com/virtuoso-blog/dbpedia-basic-queries-bc1ac172cc09
- docs:
  - https://www.dbpedia.org/resources/sparql/
  - https://docs.ruby-lang.org/en/2.1.0/URI.html
  - https://apidock.com/ruby/URI/encode_www_form/class
- YouTube:
  - [AM Coder - Ruby - Sinatra - #1 Introduction - routes, url params, queries, json](https://www.youtube.com/watch?v=xnoPoerYI0o) by [Web Development with Alex Merced](https://www.youtube.com/@AlexMercedCoder)
  - [SPARQL in 11 minutes](https://www.youtube.com/watch?v=FvGndkpa4K0) by [bobdc](https://www.youtube.com/@bobdc)

## <a name="deliverables"></a> 5. Deliverables

### MVP: Browser

To retrieve films by actor or actors by film, navigate to the following URLs in your browser:

- To retrieve films by actor or actors by film, navigate to the following URLs in your browser:

```zsh
  http://localhost:9292/?actor=<Actor_Name>

```

example:

```zsh
  http://localhost:9292/?actor=Sigourney%20Weaver
```

- http://localhost:9292/?film=<Film_Title>

Actors by film:

```url
http://localhost:9292/?film=<Film_Title>
```

example

```url
http://localhost:9292/?film=My%20Girl
```

### MVP: cURL

You can also use cURL to make requests:

Films by actor example:

```zsh
curl "http://localhost:9292/?actor=Sigourney%20Weaver"
```

Actors by film example:

```zsh
curl "http://localhost:9292/?film=My%20Girl"
```

## <a name="planning"></a>6. Planning / Build Process

### 17/07/2024

## 7. <a name="challenges"></a> Challenges

- redirects

```ruby
def make_query(query_params)

  # create uri object
  uri = URI(ENDPOINT_URL)

  # encode query params into a query string + add to uri
  uri.query = URI.encode_www_form(query: query_params, format: 'json')

  # send a HTTP GET request to endpoint url + get a response
  response = Net::HTTP.get(uri)
  puts JSON.parse(response.body)

  # parse the body of the HTTP response from JSON into a ruby hash
  JSON.parse(res.body)

end
```

- solution: httparty gem:

```ruby
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
```

The issue you're encountering is due to the fact that DBpedia's data often contains redundant or repeated entries for the same information. In this case, you see multiple instances of the same actor's name being returned for "Total Recall."

To handle this, you can modify your script to remove duplicates from the results before displaying them. Here’s how you can adjust your get_actors_by_film function to achieve this:

Step-by-Step Explanation
SPARQL Query Construction: Constructs a SPARQL query to retrieve actor names for a given film.
Calling make_query: Calls the make_query function with the constructed SPARQL query.
Extracting and Filtering Results: Extracts actor names from the query result and removes duplicates.

Optimize the SPARQL Query: Use the DISTINCT keyword to ensure that the results are unique at the SPARQL query level.
Optimize the Ruby Script: Process the results efficiently to handle any unexpected data and ensure the final output is as expected.
Optimized SPARQL Query with DISTINCT
Using DISTINCT in the SPARQL query will help in getting unique actor names directly from the query result, reducing the need for additional processing in Ruby.

We will ensure the SPARQL query uses DISTINCT properly. We can further refine the FILTER clause to match exactly with the film name. This should reduce the number of returned results and improve performance.

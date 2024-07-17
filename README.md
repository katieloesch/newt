# Newt

### build process: 17/07/2024

### resources + tutorials

- medium:
  - https://medium.com/virtuoso-blog/dbpedia-basic-queries-bc1ac172cc09
- docs:

  - https://www.dbpedia.org/resources/sparql/
  - https://docs.ruby-lang.org/en/2.1.0/URI.html
  - https://apidock.com/ruby/URI/encode_www_form/class

- YouTube:
  - [AM Coder - Ruby - Sinatra - #1 Introduction - routes, url params, queries, json](https://www.youtube.com/watch?v=xnoPoerYI0o) by [Web Development with Alex Merced](https://www.youtube.com/@AlexMercedCoder)
  - [SPARQL in 11 minutes](https://www.youtube.com/watch?v=FvGndkpa4K0) by [bobdc](https://www.youtube.com/@bobdc)

# issues

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

```

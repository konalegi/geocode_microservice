# README

Available functions:
- Geocode using multiiple adapter
  Supported adapters
    * Google
    * Yandex
    * DaData

- Identify distance of the route outside of the city with predefined city boundaries.

# Prepare database
`docker-compose run --rm web rails db:create db:migrate`

# Import city boundaries  
  `docker-compose run --rm web rails city_boundaries:import`  

# To start http endpoint.
`docker-compose up -d`

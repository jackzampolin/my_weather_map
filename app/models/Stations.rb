class Stations
  # Sets the Station and Forecast database values.  Uses the Hourly class to filter the forecast data coming in.
  def self.set_forecasts
    # SF_STATIONS explaination in the environment.rb file.
    # geo_points = WUHTTP.make_array(SF_CORNERS[0],SF_CORNERS[1],SF_CORNERS[2],SF_CORNERS[3],40)
    # geo_points.each do |latlng|
    #   raw_json = WUHTTP.send_request(WUHTTP.query_string("#{latlng[0]},#{latlng[1]}",'geolookup')).body
    #   raw_json['location']['nearby_weather_stations']['pws']['station'].each do |station_hash|
    #     new_station = Station.create(
    #       lat: station_hash['lat'],
    #       lng: station_hash['lon'],
    #       pws_id: station_hash['id']
    #     )
    #   end
    # end
    SF_STATIONS.each do |station|
      new_station = Station.create(
        lat: station['lat'],
        lng: station['lng'],
        pws_id: station['pws_id']
      )
      hourly = Hourly.new("pws:#{station['pws_id']}")
      forecast = Forecast.create(
        station_id: station,
        feelslike: hourly.feelslike.to_json,
        temp: hourly.temp.to_json,
        dewpoint: hourly.dewpoint.to_json,
        wind_speed: hourly.wind_speed.to_json,
        wind_direction: hourly.wind_direction.to_json,
        humidity: hourly.humidity.to_json
      )
      new_station.forecast_id = forecast.id
      new_station.save
    end
  end
end
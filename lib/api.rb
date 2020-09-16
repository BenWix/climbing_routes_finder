require_relative '../config/environment'


class Api 
    KEY = ENV['MP_KEY']
    
    def self.get_routes(location)
        url = "https://www.mountainproject.com/data/get-routes-for-lat-lon?lat=#{location.lat}&lon=#{location.lon}&maxDistance=#{location.range}&minDiff=5.#{location.min_grade}&maxDiff=5.#{location.max_grade}&maxResults=#{location.route_count}&key=#{KEY}"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        routes = JSON.parse(response.body)
        routes["routes"]
        
    end 


        
end 
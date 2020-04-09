require_relative '../config/environment'


class Api 
    KEY = ENV['MP_KEY']
    "https://www.mountainproject.com/data/get-routes-for-lat-lon?lat=40.03&lon=-105.25&maxDistance=10&minDiff=5.6&maxDiff=5.10&key=#{KEY}"
    
    def self.get_routes(location)
        url = "https://www.mountainproject.com/data/get-routes-for-lat-lon?lat=#{location.lat}&lon=#{location.lon}&maxDistance=#{location.range}&minDiff=#{location.min_grade}&maxDiff=#{location.max_grade}&maxResults=#{location.route_count}&key=#{KEY}"
        #puts url 
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        routes = JSON.parse(response.body)
        routes["routes"]
        
        #binding.pry
    end 


        
end 
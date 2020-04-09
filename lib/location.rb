class Location 
    attr_accessor :route_count, :min_grade, :max_grade, :routes, :range
    attr_reader :lat, :lon, :name
    
    @@all = []

    require 'pry'
    require 'geocoder'

    def initialize(lat, lon, place)
        @lat = lat
        @lon =lon 
        @place = place
        @route_count = 0 
        @range = 10
        @min_grade = "5.1"
        @max_grade = "5.15d"
        @routes = []
        @sort = "name"
        get_and_add_routes
        save
    end

    def get_and_add_routes
        @route_count += 50
        data = Api.get_routes(self)
        data.each do |route|
            new_route = Route.new_from_hash(route, self)
            @routes << new_route
        end
    end 

    def list_routes
        case @sort
        when "name"
            @routes.sort_by{|o| o.name}
        when "type"
            @routes.sort_by{|o| o.type}
        when "grade"
            @routes.sort_by{|o| o.grade}
        end 
        @routes.each.with_index(1) do |route, index|
            puts "#{index}. #{route.name}: grade #{route.grade}, type #{route.type}. stars #{route.stars}"
        end 
    end 
    
    def save
        @@all << self
    end 

    
    def self.list_locations
        self.all.each.with_index(1) do |item, index| 
            puts "#{index}. #{item.name}"
        end     
    end 
    
    def self.create_from_place(place) 
        geocode_obj = Geocoder.search(place).first 
        unless geocode_obj == nil
            lat,lon = geocode_obj.coordinates
            Location.new(lat, lon, place)

        else 
            puts "\nLooks like we couldn't find that place. Try again."
            place = gets.strip
            create_from_place(place)
        end 
    end 

    def self.all 
        @@all 
    end 
end 
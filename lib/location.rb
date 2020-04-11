class Location 
    attr_accessor :route_count, :min_grade, :max_grade, :routes, :range
    attr_reader :lat, :lon, :place
    
    @@all = []

    require 'pry'
    require 'geocoder'

    def initialize(lat, lon, place)
        @lat = lat
        @lon =lon 
        @place = place
        @route_count = 0 
        @range = 20
        @min_grade = "5.1"
        @max_grade = "5.15d"
        @routes = []
        @sort = "name"
        get_and_add_routes
        save
    end

    def get_and_add_routes
        @route_count += 25
        data = Api.get_routes(self)
        data.each do |route|
            unless Route.all_ids.include?(route["id"]) 
                new_route = Route.new_from_hash(route, self)
                @routes << new_route
            end 
        end
    end 

    def list_routes
        filter_routes
        sort_routes
        puts "\nHere are some routes in #{self.place}!\n"
        @filtered_routes.each.with_index(1) do |route, index|
            puts "#{index}. #{route.name}: grade 5.#{route.grade}, type #{route.type}. stars #{route.stars}"
        end 
        puts " "
    end 

    def choose_sort 
        puts "Would you like to sort the routes by name, grade, or stars?"
        answer = gets.strip.downcase
        choices = %w[name grade stars]
        if choices.include?(answer)
            @sort = answer
        else 
            puts "\nSorry, that is not a valid option. Please Try again.\n"
            choose_sort
        end 
    end 

    def choose_filter 
        puts "Would you like to filter by grade, or type"
        answer = gets.strip
        case answer
        when "grade"
            grade_filter
        when "type"
            type filter
        else 
            puts "Sorry, I didn't understand that. Please try again."
            choose_filter
        end 
    end 

    def filter_routes
        @filtered_routes = @routes
    end 

    def sort_routes 
        case @sort
        when "name"
            @filtered_routes.sort_by!{|o| o.name}
        when "grade"
            @filtered_routes.sort_by!{|o| [o.grade[/[0-9]+/].to_i, o.grade[/[a-z]/]]}
        when "stars"
            @filtered_routes.sort_by!{|o| o.stars}.reverse!
        end
    end 

    def save
        @@all << self
    end 

    ###Class Methods###
    def self.list_locations
        all.each.with_index(1) do |item, index| 
            puts "#{index}. #{item.place}"
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
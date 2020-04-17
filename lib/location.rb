class Location 
    attr_accessor :route_count, :min_grade, :max_grade, :routes, :range, :sort, :available_types, :filtered_routes
    attr_reader :lat, :lon, :place
    
    @@all = []
    GRADE_ORDER = ["1-", "1", "1+", "2-", "2", "2+", "3-", "3", "3+", "4-", "4", "4+", "5-", "5", "5+", "6-", "6", "6+", "7-", "7", "7+", "8-", "8", "8+", "9-", "9", "9+", "10a", "10a/b", "10-", "10b", "10", "10b/c", "10c", "10+", "10c/d", "10d", "11a", "11a/b", "11-", "11b", "11", "11b/c", "11c", "11+", "11c/d", "11d", "12a", "12a/b", "12-", "12b", "12", "12b/c", "12c", "12+", "12c/d", "12d", "13a", "13a/b", "13-", "13b", "13", "13b/c", "13c", "13+", "13c/d", "13d", "14a", "14a/b", "14-", "14b", "14", "14b/c", "14c", "14+", "14c/d", "14d", "15a", "15a/b", "15-", "15b", "15", "15b/c", "15c", "15+", "15c/d", "15d"]



    def initialize(lat, lon, place)
        @lat = lat             #longitude determined by geocode
        @lon =lon              #longitude determined by geocode
        @place = place         #Name of location entered by user
        
        #Has Many array
        @routes = []
        
        #variable to control API
        @range = 20            #The range (in miles) that the api will search from the chosen location
        @route_count = 0       #How many routes the api class will pull from the api
        
        #Default values for sort order and filtering
        @min_grade = "1"                       #Default minimum route grade
        @max_grade = "15d"                     #Default maximum route grade
        @available_types = ["sport", "trad", "tr"]   #Variable used to filter between sport and trad climbs
        @sort = "name"                         #Default to sorting by name
        
        get_and_add_routes                     #Gets 25 routes from api and creates route objects, adds to @routes
        save unless @routes.length == 0
    end 

    def get_and_add_routes
        @route_count += 25         #each time this is run, the program will expand the route count pulled from the API by 25 routes
        data = Api.get_routes(self)
        data.each do |route|       #Instanciates a new route object unless it already exitst and adds it to the @route array
            unless Route.all_ids.include?(route["id"]) 
                new_route = Route.new_from_hash(route, self)
                @routes << new_route
            end 
        end
    end 

    def clear_filter
        @min_grade = "1"
        @max_grade = "15d"
        @available_types = ["sport", "trad", "tr"]
    end 
 
    def filter_and_sort_routes
        @filtered_routes = @routes.select{|r| 
            GRADE_ORDER.index(r.grade.split.first) >= GRADE_ORDER.index(@min_grade) &&
            GRADE_ORDER.index(r.grade.split.first) <= GRADE_ORDER.index(@max_grade)}
        @filtered_routes.select!{|r| @available_types.any?{|type| r.type.downcase.include?(type)}}
        case @sort
        when "name"
            @filtered_routes.sort_by!{|o| o.name}
        when "grade"
            @filtered_routes.sort_by!{|o| GRADE_ORDER.index(o.grade.split.first)}
        when "stars"
            @filtered_routes.sort_by!{|o| o.stars}.reverse!
        end
    end 

    def save
        @@all << self
    end 

    ###Class Methods###
 
    def self.create_from_place(place) 
        geocode_obj = Geocoder.search(place).first 
        unless geocode_obj == nil
            lat,lon = geocode_obj.coordinates
            Location.new(lat, lon, place)
        else 
            nil
        end 
    end 

    def self.all 
        @@all 
    end 
end 
class Route
    attr_accessor :name, :grade, :type, :stars, :id, :location
    @@all = []

    def initialize(name, grade, type, stars, id, location)
        @name = name
        @grade = grade 
        @type = type 
        @stars = stars
        @id = id
        @location = location
        save 
    end 

    def save
        @@all << self 
    end

    ###Class Methods###
    def self.all 
        @@all
    end 

    def self.all_ids
        @route_ids = all.map{|route| route.id}
    end
    
    def self.new_from_array(routes, location) 
        routes.each do |route|
            name = route["name"] 
            grade = route["rating"] 
            type = route["type"] 
            stars = route["stars"]
            id = route["id"]
            unless all_ids.include?(id)
                Route.new(name, grade, type, stars, id, location)
            end 
        end 
    end 

    def self.new_from_hash(route_hash, location)
        name = route_hash["name"] 
        grade = route_hash["rating"] 
        type = route_hash["type"] 
        stars = route_hash["stars"]
        id = route_hash["id"]
        Route.new(name, grade, type, stars, id, location)
    end 
        
    def self.get_routes_by_location(location)
        selected_routes = Route.all.select{|route| route.location == location}
        # selected_routes.all.each.with_index(1) do |route, index|
        #     puts "#{index}.#{route.name}: grade #{route.grade}, type #{route.type}. stars #{route.stars}"
        # end 
    end
end 
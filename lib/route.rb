class Route
    attr_accessor :name, :grade, :type, :stars, :id, :location
    @@all = []

    def initialize(name, grade, type, stars, id, location)
        @name = name
        @grade = grade.split(".")[1] 
        @type = type 
        @stars = stars
        @id = id
        @location = location
        save 
    end 

    def display_info

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

    def self.new_from_hash(route_hash, location)
        name = route_hash["name"] 
        grade = route_hash["rating"] 
        type = route_hash["type"] 
        stars = route_hash["stars"]
        id = route_hash["id"]
        Route.new(name, grade, type, stars, id, location)
    end 
        

    # def self.get_routes_by_location(location)
    #     selected_routes = Route.all.select{|route| route.location == location}
    # end
end 
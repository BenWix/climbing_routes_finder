class Route
    attr_reader :name, :grade, :type, :stars, :id, :location, :specific_location, :pitches
    @@all = []

    def initialize(name, grade, type, stars, id, specific_location, pitches, location)
        @name = name
        @grade = grade.split(".")[1] 
        @type = type 
        @stars = stars
        @id = id
        @pitches = pitches  
        @location = location
        @specific_location = specific_location
        save 
    end 

    def display_info
        puts "Name: #{@name}"
        puts "Grade: #{@grade}"
        puts "Stars: #{@stars}"
        puts "Type: #{@type}"
        puts "Number of Pitches: #{@pitches}"
        puts "Directions: #{@specific_location}"
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
        pitches = route_hash["pitches"]
        specific_location = route_hash["location"].join(" >> ")
        Route.new(name, grade, type, stars, id, specific_location, pitches, location)
    end 
        

    # def self.get_routes_by_location(location)
    #     selected_routes = Route.all.select{|route| route.location == location}
    # end
end 
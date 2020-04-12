class Location 
    attr_accessor :route_count, :min_grade, :max_grade, :routes, :range
    attr_reader :lat, :lon, :place
    
    @@all = []
    

    require 'pry'
    require 'geocoder'

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
        @available_types = ["sport", "trad"]   #Variable used to filter between sport and trad climbs
        @sort = "name"                         #Default to sorting by name
        @grade_order = Location.make_order     #Creates array to determine order of climbing grades
        
        get_and_add_routes                     #Gets 25 routes from api and creates route objects, adds to @routes
        save                                   #save this location
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
        puts "Would you like to filter by grade, or type. Or enter 'clear' to clear all filters."
        answer = gets.strip
        case answer
        when "grade"
            grade_filter
        when "type"
            type_filter
        when "clear"
            clear_filter
        else 
            puts "Sorry, I didn't understand that. Please try again."
            choose_filter
        end 
    end 

    def grade_filter
        puts "What would you like the lower grade threshhold to be? \nEnter 'help' to learn about climbing grades."
        lower_grade = gets.chomp
        if lower_grade == "help"
            help_list
            grade_filter
            return
        end 
        
        checked_lower_grade = grade_converter(lower_grade)
        if checked_lower_grade 
            @min_grade = checked_lower_grade 
        else
            puts "That is not a valid grade. Lets try again."
            grade_filter
        end
        
        puts "What would you like the upper grade threshhold to be? \nEnter 'help' to learn about climbing grades."
        upper_grade = gets.chomp
        if upper_grade.downcase == "help"
            help_list
            grade_filter
            return
        end
        checked_upper_grade = grade_converter(upper_grade)
        if checked_upper_grade 
            @max_grade = checked_upper_grade 
        else 
            puts "That is not a valid grade. Lets try again."
            grade_filter
        end
    end 

    def type_filter
        puts "\nWould you like to look at 'sport' or 'trad' climbs?"
        answer = gets.chomp.downcase
        case answer
        when "sport"
            @available_types = ["sport"]
        when "trad"
            @available_types = ["trad"]
        else 
            puts "\nWhoops, I didn't understand that. Let's try again"
            type_filter
        end 
    end 

    def clear_filter
        @min_grade = "1"
        @max_grade = "15d"
        @available_types = ["sport", "trad"]
    end 


    def grade_converter(grade)
        test1 = @grade_order.include?(grade.split(".")[1])
        test2 = grade[0] == "5"
        if test1 && test2 
            modified_grade = grade.split(".")[1][0..2]
            modified_grade["+"] = "d" if modified_grade.include?("+")
            modified_grade["-"] = "a" if modified_grade.include?("-")
            modified_grade
        else 
            false
        end 
    end 

    def help_list 
        puts "Climbing grades are confusing"
    end 
    
    def filter_routes
        #binding.pry 
        @filtered_routes = @routes.select{|r| 
            @grade_order.index(r.grade.split.first) >= @grade_order.index(@min_grade) &&
            @grade_order.index(r.grade.split.first) <= @grade_order.index(@max_grade)}
        @filtered_routes.select!{|r| @available_types.include?(r.type.downcase)}
    end 

    def sort_routes 
        case @sort
        when "name"
            @filtered_routes.sort_by!{|o| o.name}
        when "grade"
            @filtered_routes.sort_by!{|o| @grade_order.index(o.grade.split.first)}
        when "stars"
            @filtered_routes.sort_by!{|o| o.stars}.reverse!
        end
    end 

    def save
        @@all << self
    end 

    ###Class Methods###
    def self.make_order
        order_array = []
        ten_through_fifteen = Array(10..15)
        one_through_nine = Array(1..9)
        
        one_through_nine.each do |num|
            order_array << "#{num}-"
            order_array << "#{num}"
            order_array << "#{num}+"
        end 
        
        ten_through_fifteen.each do |num|
            order_array << "#{num}a"
            order_array << "#{num}a/b"
            order_array << "#{num}-"
            order_array << "#{num}b"
            order_array << "#{num}"
            order_array << "#{num}b/c"
            order_array << "#{num}c"
            order_array << "#{num}+"
            order_array << "#{num}c/d"
            order_array << "#{num}d"
        end 
        order_array
    end 

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
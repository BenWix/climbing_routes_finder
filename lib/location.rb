class Location 
    attr_accessor :route_count, :min_grade, :max_grade, :routes, :range
    attr_reader :lat, :lon, :place
    
    @@all = []
    GRADE_ORDER = ["1-", "1", "1+", "2-", "2", "2+", "3-", "3", "3+", "4-", "4", "4+", "5-", "5", "5+", "6-", "6", "6+", "7-", "7", "7+", "8-", "8", "8+", "9-", "9", "9+", "10a", "10a/b", "10-", "10b", "10", "10b/c", "10c", "10+", "10c/d", "10d", "11a", "11a/b", "11-", "11b", "11", "11b/c", "11c", "11+", "11c/d", "11d", "12a", "12a/b", "12-", "12b", "12", "12b/c", "12c", "12+", "12c/d", "12d", "13a", "13a/b", "13-", "13b", "13", "13b/c", "13c", "13+", "13c/d", "13d", "14a", "14a/b", "14-", "14b", "14", "14b/c", "14c", "14+", "14c/d", "14d", "15a", "15a/b", "15-", "15b", "15", "15b/c", "15c", "15+", "15c/d", "15d"]
    

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
        @available_types = ["sport", "trad", "tr"]   #Variable used to filter between sport and trad climbs
        @sort = "name"                         #Default to sorting by name
        
        get_and_add_routes                     #Gets 25 routes from api and creates route objects, adds to @routes
        if @routes.length == 0
            puts "Looks like there are no routes in this area. Sorry."
        else 
            save                                   #save this location
        end
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

    def list_routes
        filter_routes    #Before the routes for each location are listed, the program will filter and sort @routes and puts it into @filtered_routes
        sort_routes
        puts "\nHere are some routes in #{self.place}!\n"
        @filtered_routes.each.with_index(1) do |route, index|
            puts "#{index}. #{route.name}: grade 5.#{route.grade}, type #{route.type}. stars #{route.stars}"
        end 
        puts " "
    end 

    def choose_sort 
        puts "Would you like to sort the routes by 'name', 'grade', or 'stars'?"
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
        puts "Would you like to filter by 'grade' or 'type'. Or enter 'clear' to clear all filters."
        answer = gets.strip.downcase
        case answer
        when "grade"
            grade_filter
        when "type"
            type_filter
        when "clear"
            clear_filter
        when "exit"
            exit!
        else 
            puts "Sorry, I didn't understand that. Please try again."
            choose_filter
        end 
    end 

    def grade_filter
        set_lower_grade
        set_upper_grade
        if GRADE_ORDER.index(@max_grade) < GRADE_ORDER.index(@min_grade)
            puts "\nLooks like your lower grade is higher than your upper grade."
            puts "\nLet's try again.\n"
            grade_filter
        end
    end 

    def set_lower_grade
        puts "\nWhat would you like the lower grade threshhold to be? \nEnter 'help' to learn about climbing grades.\n"
        lower_grade = gets.chomp
        if lower_grade == "help"
            help_list
            set_lower_grade
        else 
            checked_lower_grade = grade_converter(lower_grade)
            if checked_lower_grade 
                @min_grade = checked_lower_grade 
            else
                puts "That is not a valid grade. Lets try again."
                set_lower_grade
            end
        end 
    end 

    def set_upper_grade
        puts "\nWhat would you like the upper grade threshhold to be? \nEnter 'help' to learn about climbing grades.\n"
        upper_grade = gets.chomp
        if upper_grade.downcase == "help"
            help_list
            set_upper_grade
        else
            checked_upper_grade = grade_converter(upper_grade)
            if checked_upper_grade 
                @max_grade = checked_upper_grade 
            else 
                puts "That is not a valid grade. Lets try again."
                set_upper_grade
            end
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
        when "exit"
            exit!
        else 
            puts "\nWhoops, I didn't understand that. Let's try again"
            type_filter
        end 
    end 

    def clear_filter
        @min_grade = "1"
        @max_grade = "15d"
        @available_types = ["sport", "trad", "tr"]
    end 


    def grade_converter(grade)
        test1 = GRADE_ORDER.include?(grade.split(".")[1])
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
        puts "\n\nClimbing grades can be confusing. In North America we use"
        puts "the Yosemite Decimal System (YDS) for climbing routes."
        puts 'YDS looks something like this  "5.10c". The first number'
        puts 'will be the class of the climb. Climb classes start at 1,'
        puts "but all of the climbs used in this project are class 5 climbs"
        puts "That means they are technical rock climbs, vertical in nature,"
        puts "and require the use of a rope for safety.  Everything afte the '.'"
        puts "Will tell the difficulty of the route. The lower the number, the"
        puts "easier the route. Once you reach 5.10, the routes are further "
        puts "divided by a letter after the number. The available letters are"
        puts "a, b, c, and d going from easiest to most difficult respectively."
        puts "So a 5.10a is easier than a 5.10c."

        puts "\nThe grades in this project starts at 5.1 and they have no upper"
        puts "limit!! However, the hardest climb in the world is a 5.15d, but "
        puts "climbers are an optimistic bunch and they want to be ready for"
        puts "even bigger and harder projects in the future.\n\n"
    end 
    
    def filter_routes
        #binding.pry 
        @filtered_routes = @routes.select{|r| 
            GRADE_ORDER.index(r.grade.split.first) >= GRADE_ORDER.index(@min_grade) &&
            GRADE_ORDER.index(r.grade.split.first) <= GRADE_ORDER.index(@max_grade)}
        @filtered_routes.select!{|r| @available_types.any?{|type| r.type.downcase.include?(type)}}
    end 

    def sort_routes 
        case @sort
        when "name"
            @filtered_routes.sort_by!{|o| o.name}
        when "grade"
            @filtered_routes.sort_by!{|o| GRADE_ORDER.index(o.grade.split.first)}
        when "stars"
            @filtered_routes.sort_by!{|o| o.stars}.reverse!
        end
    end 

    def route_info
        puts "\nPlease enter the name of one of the above routes.\n"
        selected_route = gets.strip.downcase
        if @filtered_routes.any?{|r| r.name.downcase.start_with?(selected_route)}
            more_info_route = @filtered_routes.find{|r| r.name.downcase.start_with?(selected_route)}
            more_info_route.display_info
        elsif selected_route == 'exit'
            Cli.run.loop
        else
            puts "\nI don't reckognize that route. Let's try again. Or type 'exit'.\n"
            route_info
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
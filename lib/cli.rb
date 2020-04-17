class Cli
    GRADE_ORDER = ["1-", "1", "1+", "2-", "2", "2+", "3-", "3", "3+", "4-", "4", "4+", "5-", "5", "5+", "6-", "6", "6+", "7-", "7", "7+", "8-", "8", "8+", "9-", "9", "9+", "10a", "10a/b", "10-", "10b", "10", "10b/c", "10c", "10+", "10c/d", "10d", "11a", "11a/b", "11-", "11b", "11", "11b/c", "11c", "11+", "11c/d", "11d", "12a", "12a/b", "12-", "12b", "12", "12b/c", "12c", "12+", "12c/d", "12d", "13a", "13a/b", "13-", "13b", "13", "13b/c", "13c", "13+", "13c/d", "13d", "14a", "14a/b", "14-", "14b", "14", "14b/c", "14c", "14+", "14c/d", "14d", "15a", "15a/b", "15-", "15b", "15", "15b/c", "15c", "15+", "15c/d", "15d"]
    
    def run
        puts "\n\nWelcome to the Climbing Route Finder.\nGive us a location, and we can find a route to fit your needs!!\n"

        run_loop
    end 
    
    def run_loop     
        main_list_options
        options = %w[1 2 list exit]
        choice = get_choice(options)
        case choice 
        when "1" 
            get_new_area
        when "2"
            get_old_area
        when "list"
            
        end 
        choice == "exit" ? exit! : run_loop
    end 

    def get_choice(choices)
        choice = gets.strip.downcase
        unless choices.include?(choice)
            puts "Sorry, I didn't understand that. Let's try again."
            puts "To see your options again enter 'list'"
            choice = get_choice(choices)
        end 
        choice 
    end 

    def choose_sort 
        puts "Would you like to sort the routes by 'name', 'grade', or 'stars'?"
        answer = gets.strip.downcase
        choices = %w[name grade stars]
        if choices.include?(answer)
            @active_location.sort = answer
        else 
            puts "\nSorry, that is not a valid option. Please Try again.\n"
            choose_sort
        end 
    end 

    
    def main_list_options
        puts "\nPlease pick one of the following options to get started"
        puts "_______________________________________________________"
        puts "1. Discover a new location"
        puts "2. Check out an old location"
        puts "enter 'exit' to leave application.\n"  
    end 

    def get_new_area
        puts "\nLet's find somewhere new to climb! Please enter a location to find routes nearby"
        puts "Feel free to enter a city, address, zip code, etc."
        location = gets.strip
        puts " "
        @active_location = Location.create_from_place(location)
        current_area_options unless @active_location.routes.length == 0
    end

    def get_old_area
        unless Location.all.length == 0
            Location.list_locations
            options = ['list', 'exit'] + Array(1..Location.all.length).map{|o| o.to_s}
            puts "\nPlease pick one of the locations from the above list"
            choice = get_choice(options)
            case choice 
            when 'list' 
                get_old_area
            when 'exit'
                run_loop
            else 
                if options.include?(choice)
                    @active_location = Location.all[choice.to_i - 1]
                else 
                    puts "Sorry, I didn't understand that. Please try again"
                    get_old_area
                end 
            end 
            current_area_options
        else 
            puts "Looks like you haven't discovered any areas yet. Lets find some."
            get_new_area
        end
    end 

    def current_area_options
        @active_location.list_routes
        list_location_options
        options = %w[1 2 3 4 5 exit list]
        choice = get_choice(options)
        case choice 
        when "1"
            @active_location.get_and_add_routes
        when "2"
            choose_filter
        when "3"
            choose_sort
        when "4"
            @active_location.route_info
        when "5"
            get_new_area
        end 
        if choice == "exit" || @active_location.routes.length == 0  
            run_loop  
        else
            current_area_options
        end 
    end 
        
    def choose_filter 
        puts "Would you like to filter by 'grade' or 'type'. Or enter 'clear' to clear all filters."
        answer = gets.strip.downcase
        case answer
        when "grade"
            grade_filter
        when "type"
            @active_location.type_filter
        when "clear"
            @active_location.clear_filter
        when "exit"
            exit!
        else 
            puts "Sorry, I didn't understand that. Please try again."
            choose_filter
        end 
    end 

    def list_location_options
        puts "\nPlease pick one of the following options to discover more."
        puts "_______________________________________________________"
        puts "1. Get more routes"
        puts "2. Filter Routes"
        puts "3. Sort Routes"
        puts "4. Get more info on a route"
        puts "5. Discover a new area"
        puts "enter 'exit' to return to main menu.\n" 
    end

    def grade_filter
        set_lower_grade
        set_upper_grade
        if GRADE_ORDER.index(@active_location.max_grade) < GRADE_ORDER.index(@active_location.min_grade)
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
                @active_location.min_grade = checked_lower_grade 
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
                @active_location.max_grade = checked_upper_grade 
            else 
                puts "That is not a valid grade. Lets try again."
                set_upper_grade
            end
        end 
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
end 
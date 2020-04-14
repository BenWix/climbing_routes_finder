class Cli
    
    def self.run
        puts "\n\nWelcome to the Climbing Route Finder.\nGive us a location, and we can find a route to fit your needs!!\n"

        run_loop
    end 
    
    private 
    
    def self.run_loop     
        main_list_options
        options = %w[1 2 list exit]
        choice = get_choice(options)
        case choice 
        when "1" 
            get_new_area
        when "2"
            get_old_area
        when "list"
            main_list_options
            choice = get_choice(options)
        end 
        choice == "exit" ? exit! : run_loop
    end 

    def self.get_choice(choices)
        choice = gets.strip.downcase
        unless choices.include?(choice)
            puts "Sorry, I didn't understand that. Let's try again."
            puts "To see your options again enter 'list'"
            choice = get_choice(choices)
        end 
        choice 
    end 
    
    def self.main_list_options
        puts "\nPlease pick one of the following options to get started"
        puts "_______________________________________________________"
        puts "1. Discover a new location"
        puts "2. Check out an old location"
        puts "enter 'exit' to leave application.\n"  
    end 

    def self.get_new_area
        puts "\nLet's find somewhere new to climb! Please enter a location to find routes nearby"
        puts "Feel free to enter a city, address, zip code, etc."
        location = gets.strip
        puts " "
        @@active_location = Location.create_from_place(location)
        current_area_options unless @@active_location.routes.length == 0
    end

    def self.current_area_options
        @@active_location.list_routes
        list_location_options
        options = %w[1 2 3 4 5 exit]
        choice = get_choice(options)
        case choice 
        when "1"
            @@active_location.get_and_add_routes
        when "2"
            #puts "We need to filter"
            @@active_location.choose_filter
        when "3"
            @@active_location.choose_sort
        when "4"
            @@active_location.route_info
        when "5"
            get_new_area
        end 
        choice == "exit" ? run_loop : current_area_options
    end 

    def self.list_location_options
        puts "\nPlease pick one of the following options to discover more."
        puts "_______________________________________________________"
        puts "1. Get more routes"
        puts "2. Filter Routes"
        puts "3. Sort Routes"
        puts "4. Get more info on a route"
        puts "5. Discover a new area"
        puts "enter 'exit' to return to main menu.\n" 
    end

    def self.get_old_area
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
                    @@active_location = Location.all[choice.to_i - 1]
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
end 
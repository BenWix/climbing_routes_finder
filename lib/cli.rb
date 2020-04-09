class Cli
    CHOICES = %w[1 2 exit]
    
    def self.run
        puts "Welcome to the Climbing Route Finder.\nGive us a location, and we can find a route to fit your needs!!\n"

        run_loop
    end 
    
    private 
    

    def self.run_loop
        
        main_list_options
        choice = get_choice
        case choice 
        when "1" 
            get_new_area
            current_area_options
        when "2"
            Location.list_locations
        end 
        run_loop unless choice == "exit"
    end 

    def self.get_choice 
        choice = gets.strip.downcase
        main_list_options if choice == "list"

        unless CHOICES.include?(choice)
            if choice == "list"
                main_list_options
            else 
                puts "Sorry, I didn't understand that. Let's try again."
                puts "To see your options again enter 'list'"
            end 
            choice = get_choice
        end 
        choice 
    end 
    
    def self.main_list_options
        puts "Please pick one of the following options to get started"
        puts "_______________________________________________________"
        puts "1. Discover a new location"
        puts "2. Check out an old location"
        puts "enter 'exit' to leave application.\n"
    end 

    def self.get_new_area
        puts "\nLet's find somewhere new to climb! Please enter a location to find routes nearby"
        location = gets.strip
        puts " "
        @@active_location = Location.create_from_place(location)
        #routes = Api.new.get_routes(new_location)
        
        #Route.new_from_array(routes)
        #Route.list_routes
        #binding.pry
    end

    def self.current_area_options
        @@active_location.list_routes
        
    end 
end 
Climbing Routes Finder CLI Project 

This CLI project will utilize the API provided by mountain project.

In order to access this api using this program. You must get a key provided by mountain project and place it in a .env file.  The .env file will be in the main project directory with the following format

MP_KEY = 'enter your key here'

The user must also run `bundle install` to have all of the required gems in the file

To learn more about Mountain Project and the API used follow this link

https://www.mountainproject.com/data


The program will let the user discover new routes in any area and will let the user filter and sort the found routes. The location if found using the geocode gem and will take a name, address, city, postal code, and many other data types to find a location. The API will find routes that are within 20 miles of the location found by geocoder. 

Once the user has found routes in an area. They will be able to get more routes, sort the routes, or filter the routes they have found. When we filter routes, in addition to filtering the routes that are already instantiated as objects, the program will also filter the API to only return new routes that match the filter if filtering by grades. All filters and sorts will be saved, even when switching through locations. All instances of locations function totally independently.


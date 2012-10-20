$:.push(File.join(File.dirname(File.expand_path(__FILE__)), "lib"))
require 'environment'

puts 
puts Time.now.strftime("%m/%d at %l:%M%P")
puts

if(ARGV[0])
  restaurants = Restaurant.find(:all, :conditions => "name LIKE '%#{ARGV[0]}%'")
  num_of_restaurants = restaurants.size
  if num_of_restaurants == 0
    raise "No restaurants found with that name!"
  elsif num_of_restaurants == 1
    puts "Found the one restaurant you wanted! #{restaurants.first}"
  else
    choices = ""
    restaurants.each_with_index { |rest, index| choices += "#{index}) #{rest.name}\n" }
    puts choices
    choice = ask("Which restaurant?  ", Integer) { |q| q.in = 0...restaurants.size }
    restaurants = [restaurants[choice]]
  end
else
  NUMBER_OF_RESTAURANTS_TO_CHECK = 0
  puts "No arguments passed. Checking the top #{NUMBER_OF_RESTAURANTS_TO_CHECK} in san francisco"
  SF_RESTAURANT_URBAN_SPOON_IDS = [2086, 971, 2908, 466, 1580, 1130, 1861, 2902, 1878, 1525, 3212, 2060, 2334, 335, 1631, 1753, 2441, 1889, 887, 1408, 2335, 4061, 3783, 2536, 2597, 1927, 1754, 1357, 3134, 2033, 1955, 1650, 2740, 2192, 1943, 2863, 3554, 3967, 1060, 1824, 1697, 2370, 1286, 2561, 1854, 2133, 4106, 2294, 3026, 2132, 892, 3798, 663, 2676, 3745, 4009, 4073, 2675, 2669, 4029, 4102, 4094]

  restaurants = []

  SF_RESTAURANT_URBAN_SPOON_IDS[0..NUMBER_OF_RESTAURANTS_TO_CHECK].each do |urban_spoon_id|
    if (restaurant = Restaurant.find_by_urban_spoon_id(urban_spoon_id))
      restaurants << restaurant
    else
      restaurant = Restaurant.create!(:urban_spoon_id => urban_spoon_id, :online_res_avail => 0)
      puts "Never seen this one before... Scraping name and address."
      restaurant.fill_data_from_urban_spoon
      restaurants << restaurant
    end
  end
end

restaurants.each do |restaurant| 
  puts; puts; puts;
  puts "Checking reservations for #{restaurant.name}"
  puts "Deleting previous reservations..."
  restaurant.reservations.each do |reservation|
    reservation.delete
  end
  
  puts "Updating reservations from Urban Spoon..."
  restaurant.update_reservations
  restaurant.reload
  
  time_til = 31.days
  
  if reservation = restaurant.nearest_reservations_within(time_til)
    nearest_res = reservation.strftime("%m/%d at %l:%M%P")
    prowl_message "Reservation Available", "There was a reservation available for #{restaurant.name}! Next available #{nearest_res}", restaurant.url
    puts "There was a reservation available! Next available #{nearest_res}"
  else
    nearest_res = restaurant.nearest_reservations.first
    puts "There was no reservation available at #{Time.now.strftime("%m/%d at %l:%M%P")} until #{Time.at(Time.now + time_til).strftime("%m/%d at %l:%M%P")}"
    if(nearest_res.exists?)
      prowl_message "The nearest reservation for #{restaurant.name} is at #{nearest_res}"
    end
    puts "The nearest reservation for #{restaurant.name} is at #{nearest_res}"
  end
end

$:.push(File.join(File.dirname(File.expand_path(__FILE__)), "lib"))
require 'environment'

restaurants = []
restaurants << Restaurant.find_by_name('State Bird Provisions')
restaurants << Restaurant.find_by_name('Mission Bowling Club Restaurant (MBC)')

restaurants.each do |restaurant| 
  restaurant.reservations.each do |reservation|
    reservation.delete
  end

  restaurant.update_reservations

  time_til = 31.days
  nearest_res = restaurant.nearest_reservations.first
  nearest_res = nearest_res.strftime("%m/%d at %l:%M%P")

  if restaurant.has_nearest_reservations_within(time_til)
    #prowl_message "Reservation Available", "There was a reservation available! Next available #{nearest_res}", restaurant.url
    puts "There was a reservation available! Next available #{nearest_res}"
  else
    puts "There was no reservation available at #{Time.now.strftime("%m/%d at %l:%M%P")} until #{Time.at(Time.now + time_til).strftime("%m/%d at %l:%M%P")}"
    puts "The nearest reservation is at #{nearest_res}"
  end
end
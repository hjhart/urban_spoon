$:.push(File.join(File.dirname(File.expand_path(__FILE__)), "lib"))
require 'environment'

STDOUT.sync = true
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

def header msg
  puts;puts;
  puts "**" * 40
  puts msg
  puts "**" * 40
  puts;puts;
end

def restaurants
  restaurants = Restaurant.all(:conditions => "name IS NOT NULL")
end

def get_most_frequent_address_attributes(count_by = :state) 
  addresses = { :state => [], :zip => [], :city => [] }
  
  restaurants.each do |rest| 
    city_state_zip = rest.address.split("|")[2]
    matches = city_state_zip.match(/(.*?), (\w+) (.*)/)
    unless matches.nil?
      city = matches[1]
      state = matches[2]
      zip = matches[3]
      addresses[:city] << city
      addresses[:state] << state
      addresses[:zip] << zip
    end
  
  output_frequencies addresses[count_by], 20
  end
end

def output_frequencies(array, max_results=20)
  b = Hash.new(0)

  # iterate over the array, counting duplicate entries
  array.each do |v|
    b[v] += 1
  end

  b.sort_by {|key, value| -(value)}.each_with_index do |(k, v), index|
    puts "#{k} appears #{v} times"
    break if index > max_results
  end
end

def address_frequencies
  # analyze city frequency
  header "Most frequent cities on urban spoon: "
  get_most_frequent_address_attributes(:city)
  # analyze state frequency
  header "Most frequent states on urban spoon: "
  get_most_frequent_address_attributes(:state)
  # analyze zip frequency (this one is particularly nasty [and uninteresting])
  header "Most frequent zip codes on urban spoon: "
  get_most_frequent_address_attributes(:zip)
end

def get_most_booked_restaurants
  results = ActiveRecord::Base.connection.execute("select count(*) as count, rest.name, rest.address from reservations res, restaurants rest where rest.id = res.restaurant_id AND rest.address LIKE '%San Francisco%' group by rest.name order by count asc;").to_a
  ap results
end

# see the most "popular" restaurants in san francisco on urban spoon.
get_most_booked_restaurants()



# uncomment this out if you want frequency statistics
# address_frequencies()


# other_restaurant.has_nearest_reservations_within(1.hour)
# reservation_distribution(state_bird)
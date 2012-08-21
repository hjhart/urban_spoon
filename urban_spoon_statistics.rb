require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'awesome_print'
require 'date'
require 'rubygems'
require 'active_record'
require 'yaml'

STDOUT.sync = true
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

class Restaurant < ActiveRecord::Base
  has_many :reservations
end

class Reservation < ActiveRecord::Base
  belongs_to :restaurant
end

def header msg
  puts;puts;
  puts "**" * 40
  puts msg
  puts "**" * 40
  puts;puts;
end

def get_most_frequent_address_attributes(count_by = :state, max_results = 20) 
  addresses = { :state => [], :zip => [], :city => [] }
  restaurants = Restaurant.all(:conditions => "name IS NOT NULL")
  
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
  
  end

  b = Hash.new(0)

  # iterate over the array, counting duplicate entries
  addresses[count_by].each do |v|
    b[v] += 1
  end

  b.sort_by {|key, value| -(value)}.each_with_index do |(k, v), index|
    puts "#{k} appears #{v} times"
    break if index > max_results
  end
end




# analyze city frequency
header "Most frequent cities on urban spoon: "
get_most_frequent_address_attributes(:city)
# analyze state frequency
header "Most frequent states on urban spoon: "
get_most_frequent_address_attributes(:state)
# analyze zip frequency (this one is particularly nasty [and uninteresting])
header "Most frequent zip codes on urban spoon: "
get_most_frequent_address_attributes(:zip)



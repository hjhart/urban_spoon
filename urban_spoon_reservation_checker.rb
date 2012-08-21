$:.push(File.join(File.dirname(File.expand_path(__FILE__)), "lib"))
require 'environment'

STDOUT.sync = true
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

numbers = (3023..5000)
numbers.each do |urban_spoon_id|
  url = "http://rez.urbanspoon.com/reservation/start/#{urban_spoon_id}?source=selfhost"
  print "Loading #{urban_spoon_id}"
  html = open(url).read
  print " L"
  var_opts = nil
  revised_title = nil
  revised_address = nil

  parsed = Nokogiri::HTML(html)

  name = parsed.css('.reserve_title')
  if name.size > 0
    revised_name =  name.first.content
  end
  
  address = parsed.css('.rest_addy')
  if address.size > 0
    revised_address = address.first.content
    revised_address = revised_address.strip.split("\n").map(&:strip).join("|")
    print " A"
  end
  
  script_tags = parsed.css('script')
  script_tags.each_with_index do |script_tag, index|
    script_content = script_tag.content
    if script_content.match(/var opts/)
      options = script_content.match(/var opts = \{(.*)\}/)
      var_opts = options[1]
      break;
    else
    end
  end
  
  online_reservations_available = !var_opts.nil?

  restaurant = Restaurant.find_or_create_by_urban_spoon_id(:urban_spoon_id => urban_spoon_id, :name => revised_name, :address => revised_address, :online_res_avail => online_reservations_available)
  
  # next; # let's keep this until we populate all of the restaurants possible
  
  if online_reservations_available
    results = var_opts.scan(/'(.*?)':'(.*?)'/)
    results.each do |(date, times)|
      times = times.scan(/(\d+:\d+ [ap]m)/)
      times.each do |time|
        datetime = DateTime.parse("#{date} #{time}")
        reservation = Reservation.create(:restaurant_id => restaurant.id, :reservation_time => datetime)
      end
    end
    puts " R"
  else
    puts ""
  end
end
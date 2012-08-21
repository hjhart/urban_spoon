ANAL_START_TIME = 18
ANAL_END_TIME = 20
ANAL_TIME = true

class Restaurant < ActiveRecord::Base
  has_many :reservations  
  
  def has_nearest_reservations_within(time_frame = 7.days, time_anal = false)
    today = Date.today
    nearest_reservations.each do |res|
      if (res - time_frame < Date.today)
        # this checks to make sure the reservations are between 6:00 and 8:59pm.
        # (anything else is a bit worthless, no?)
        if ANAL_TIME
          hour = res.strftime('%H').to_i
          if (hour > ANAL_START_TIME && hour < ANAL_END_TIME)
            return true 
          else
            puts "Reservation found, but the start time was not acceptable. (Switch ANAL_TIME to false if you don't care)"
          end
        else
          return true 
        end
      end
    end
    false
  end
  
  def nearest_reservations
    rezs = reservations.map(&:reservation_time).sort
    rezs[0..2]
  end

  def reservation_distribution
    reservations = reservations.map do |res|
      res.reservation_time.strftime("%m-%d")
    end
    output_frequencies reservations
  end
  
  def update_reservations
    puts "Updating reservations"
    
    puts "Opening the page"
    html = open(url).read
    puts "Loaded!"
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

    if online_reservations_available
      results = var_opts.scan(/'(.*?)':'(.*?)'/)
      results.each do |(date, times)|
        times = times.scan(/(\d+:\d+ [ap]m)/)
        times.each do |time|
          datetime = DateTime.parse("#{date} #{time}")
          reservation = Reservation.create(:restaurant_id => self.id, :reservation_time => datetime)
        end
      end
    end
    
    puts "Aded #{Reservation.count(:conditions => { :restaurant_id => self.id })} reservations!"
  end
  
  def url
    "http://rez.urbanspoon.com/reservation/start/#{urban_spoon_id}?source=selfhost"
  end
end

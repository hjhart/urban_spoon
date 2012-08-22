ANAL_START_TIME = 18
ANAL_END_TIME = 20
ANAL_TIME = true

class Restaurant < ActiveRecord::Base
  has_many :reservations  
  
  def fill_data_from_urban_spoon
    raise "You must specify a urban_spoon_id first!" if urban_spoon_id.nil?
    
    html = open(url).read
    revised_title = nil
    revised_address = nil
    var_opts = nil

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

    update_attributes!(:urban_spoon_id => urban_spoon_id, :name => revised_name, :address => revised_address, :online_res_avail => online_reservations_available)
  end
  
  def nearest_reservations_within(time_frame = 7.days, time_anal = false)
    if ANAL_TIME
      reservations = nearest_anal_reservations
    else
      reservations = nearest_resrvations
    end
    
    ap "Found reservations"
    ap reservations
    
    reservations.each do |res|
      if (res - time_frame < Date.today)
        puts "You found yourself a reservation!"
        return res
      end
    end
    false
  end
  
  def nearest_anal_reservations
    reservations = connection.execute("SELECT CAST(strftime('%H%M', reservation_time) AS INTEGER) hour, id from reservations where hour > #{ANAL_START_TIME}00 AND hour < #{ANAL_END_TIME}60 AND restaurant_id = #{id} ORDER BY reservation_time;").to_a
    reservations.map{ |res| Reservation.find(res["id"]).reservation_time }
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
    html = open(url).read
    puts "Webpage loaded!"
    var_opts = nil
    revised_title = nil
    revised_address = nil

    parsed = Nokogiri::HTML(html)

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
    
    puts "Added #{Reservation.count(:conditions => { :restaurant_id => self.id })} reservations!"
  end
  
  def url
    "http://rez.urbanspoon.com/reservation/start/#{urban_spoon_id}?source=selfhost"
  end
end

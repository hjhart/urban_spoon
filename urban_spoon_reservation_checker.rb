require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'awesome_print'
require 'date'
require 'sqlite'

# integer = 2086

numbers = (2086..2100)
numbers.each do |integer|
  url = "http://rez.urbanspoon.com/reservation/start/#{integer}?source=selfhost"
  puts "#{url}.. opening.."
  html = open(url).read
  puts "#{url}\n: This page is #{html.size} this big."

  parsed = Nokogiri::HTML(html)

  title = parsed.css('.reserve_title')
  if title.size > 0
    title =  title.first.content
    puts "Revised title #{title}"
  end
  
  address = parsed.css('.rest_addy')
  if address.size > 0
    address =  address.first.content
    puts "Revised address #{address}"
  end
  
    
    
  script_tags = parsed.css('script')
  script_tags.each_with_index do |script_tag, index|
    var_opts = nil
    script_content = script_tag.content
    if script_content.match(/var opts/)
      puts "We found one with var opts!"
      options = script_content.match(/var opts = \{(.*)\}/)
      var_opts =  options[1]
      results = var_opts.scan(/'(.*?)':'(.*?)'/)
      results.each do |(date, times)|
        # date = Date.parse(date)
        times = times.scan(/(\d+:\d+ [ap]m)/)
        times.each do |time|
          datetime = DateTime.parse("#{date} #{time}")
        end
      end
    end
  end
end
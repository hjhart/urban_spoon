def prowl_message event, description, url=nil
  require 'prowl'
  
  prowl_config_file = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'prowl.yml')
  if File.exists? prowl_config_file
    prowl_config = YAML.load File.open(prowl_config_file).read
    if prowl_config["active"]
      Prowl.add(
        :apikey => prowl_config["api_key"],
        :application => "CraigsWarn",
        :event => event,
        :description => description,
        :url => url
      )
    end
    puts "Prowl notification sent '#{event}'"
  else
    raise "The prowl configuration couldn't be found! Please add a prowl.yml file to your project."
  end
end

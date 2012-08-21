require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'awesome_print'
require 'date'
require 'rubygems'
require 'active_record'
require 'yaml'
require 'prowl_notifier'
require 'restaurant'
require 'reservation'

STDOUT.sync = true
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)


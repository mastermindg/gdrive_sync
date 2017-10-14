require "google_drive"
require "rb-inotify"
require 'json'

puts "#### RUN THIS FILE FIRST TO GET YOUR APP CODE #####"
puts
puts "Follow the instructions below:"
puts
session = GoogleDrive::Session.from_config("config.json")

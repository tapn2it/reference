#!/usr/bin/ruby -w
# drivers.rb - exercise available_drivers method

require "dbi"

puts "Ruby DBI driver list:"
begin
  DBI::available_drivers.each do |name|
    puts name
  end
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
end

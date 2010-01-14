#!/usr/bin/ruby -w
# select_all.rb - show how select_all method works

# This script runs a SHOW VARIABLES query, which returns two columns
# containing the names and values of the server variables.  The script
# uses the result to construct a hash keyed by variable name.

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
  rows = dbh.select_all("SHOW VARIABLES")
  vars = {}
  rows.each do |row|
    vars[row[0]] = row[1]
  end

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

puts "Server variables:"
vars.keys.sort.each do |key|
  puts "#{key} = #{vars[key]}"
end


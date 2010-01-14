#!/usr/bin/ruby -w
# simple.rb - simple MySQL script using Ruby DBI module

require "dbi"

begin
  # connect to the MySQL server
#@ _CONNECT_
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
#@ _CONNECT_
  # get server version string and display it
  row = dbh.select_one("SELECT VERSION()")
  puts "Server version: " + row[0]
#@ _EXCEPTION_
rescue DBI::DatabaseError => e
  puts "An error occurred"
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
#@ _EXCEPTION_
ensure
  # disconnect from server
  dbh.disconnect if dbh
end


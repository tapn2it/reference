#!/usr/bin/ruby -w
# simple2.rb - simple MySQL script using Ruby DBI module

require "dbi"

begin
  # connect to the MySQL server
#@ _CONNECT_
  dsn = "DBI:Mysql:host=localhost;mysql_read_default_group=client"
  dbh = DBI.connect(dsn,nil,nil)
#@ _CONNECT_
  # get server version string and display it
  row = dbh.select_one("SELECT VERSION()")
  puts "Server version: #{row[0]}"
  # get database and display it (likely empty; no db has been selected)
  row = dbh.select_one("SELECT DATABASE()")
  puts "Database: #{row[0]}"
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


#!/usr/bin/ruby -w
# simple.rb - simple MySQL script using Ruby MySQL module

require "mysql"

begin
  # connect to the MySQL server
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")
  # get server version string and display it
  puts "Server version: " + dbh.get_server_info
rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  # disconnect from server
  dbh.close if dbh
end

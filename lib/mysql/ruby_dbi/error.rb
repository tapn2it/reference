#!/usr/bin/ruby -w
# error.rb - show all error values (err, errstr, state)

require "dbi"

begin
  # connect to the MySQL server
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
  # issue syntactically invalid statement to force an error to occur
  row = dbh.select_one("SELECT")
  puts "Server version: " + row[0]
#@ _EXCEPTION_
rescue DBI::DatabaseError => e
  puts "An error occurred"
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
  puts "Error SQLSTATE: #{e.state}"
#@ _EXCEPTION_
ensure
  # disconnect from server
  dbh.disconnect if dbh
end


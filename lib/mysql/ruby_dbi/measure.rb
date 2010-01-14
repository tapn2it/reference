#!/usr/bin/ruby -w
# measure.rb - Try DBI::Utils.measure method to measure statement execution time

# The program runs a default statement, which can be overridden by supplying
# a statement as an argument on the command line.

require "dbi"

stmt = "SHOW VARIABLES"
# override statement with command line argument if one was given
stmt = ARGV[0] if ARGV.length > 0

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
#@ _MEASURE_
  elapsed = DBI::Utils::measure do
    dbh.do(stmt) 
  end
  puts "Statement: #{stmt}"
  puts "Elapsed time: #{elapsed}"
#@ _MEASURE_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

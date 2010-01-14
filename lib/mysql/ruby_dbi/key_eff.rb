#!/usr/bin/ruby -w
# key_eff.rb - Determine index cache key read efficiency

# This is determined based on the values of the Key_read_requests and
# Key_reads status variables, which indicate the number of requests to
# read an index block from the index cache, and the number of physical
# index block reads from disk.

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
  # SHOW STATUS variable name and value are in columns 0 and 1
  reqs = dbh.select_one("SHOW STATUS LIKE 'Key_read_requests'")[1].to_f
  reads = dbh.select_one("SHOW STATUS LIKE 'Key_reads'")[1].to_f
  reqs = 0.0 if reqs.nil?
  reads = 0.0 if reads.nil?
  if reqs == 0.0
    eff = 0.0
  else
    eff = 100 - ((reads / reqs) * 100)
  end
  puts "Key read requests: #{reqs}"
  puts "Key reads: #{reads}"
  puts "Key efficiency: #{eff}"
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end


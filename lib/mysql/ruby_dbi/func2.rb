#!/usr/bin/ruby -w
# func2.rb - demonstrate use of func method to get at MySQL driver-specific
# createdb and reload methods

require "dbi"

# Invoke createdb as database handle object method.
# (This actually will always fail for MySQL 4 and higher, because
# as of MySQL 4, the create_db method is not defined in the
# MySQL Ruby module that underlies DBD::Mysql)

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
#@ _CREATEDB_
  dbh.func(:createdb, "newdb")
#@ _CREATEDB_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

# invoke reload as database handle object method

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
#@ _RELOAD_
  dbh.func(:reload)
#@ _RELOAD_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

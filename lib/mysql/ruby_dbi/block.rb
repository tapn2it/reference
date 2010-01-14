#!/usr/bin/ruby -w
# block.rb - demonstrate methods that can take a code block, passing a
# handle to the block and cleaning up the handle at the end of the block

require "dbi"

begin
#@ _BLOCK_
  # connect can take a code block, passes the database handle to it,
  # and automatically disconnects the handle at the end of the block

  DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass") do |dbh|

    # prepare can take a code block, passes the statement handle
    # to it, and automatically calls finish at the end of the block

    dbh.prepare("SHOW DATABASES") do |sth|
      sth.execute
      puts "Databases: " + sth.fetch_all.join(", ")
    end

    # execute can take a code block, passes the statement handle
    # to it, and automatically calls finish at the end of the block

    dbh.execute("SHOW DATABASES") do |sth|
      puts "Databases: " + sth.fetch_all.join(", ")
    end
  end
#@ _BLOCK_

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
end


#!/usr/bin/ruby -w
# meta.rb - run a statement and display its result set metadata

# The program runs a default statement, which can be overridden by
# supplying a statement as an argument on the command line.

require "mysql"

stmt = "SELECT name, category FROM animal"
# override statement with command line argument if one was given
stmt = ARGV[0] if ARGV.length > 0

begin
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")

  # issue a statement and retrieve the column metadata
#@ _METADATA_
  res = dbh.query(stmt)

  puts "Statement: #{stmt}"
  if res.nil? then
    puts "Statement has no result set"
    printf "Number of rows affected: %d\n", dbh.affected_rows
  else
    puts "Statement has a result set"
    printf "Number of rows: %d\n", res.num_rows
    printf "Number of columns: %d\n", res.num_fields
    res.fetch_fields.each_with_index do |info, i|
      printf "--- Column %d (%s) ---\n", i, info.name
      printf "table:            %s\n", info.table
      printf "def:              %s\n", info.def
      printf "type:             %s\n", info.type
      printf "length:           %s\n", info.length
      printf "max_length:       %s\n", info.max_length
      printf "flags:            %s\n", info.flags
      printf "decimals:         %s\n", info.decimals
    end
    res.free
  end
#@ _METADATA_

rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  dbh.close if dbh
end

#!/usr/bin/ruby -w
# meta.rb - run a statement and display its result set metadata

# The program runs a default statement, which can be overridden by
# supplying a statement as an argument on the command line.

require "dbi"

stmt = "SELECT * FROM people"
# override statement with command line argument if one was given
stmt = ARGV[0] if ARGV.length > 0

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")

  # issue a statement and retrieve the column metadata
#@ _METADATA_
  sth = dbh.execute(stmt)

  puts "Statement: #{stmt}"
  if sth.column_names.size == 0 then
    puts "Statement has no result set"
    printf "Number of rows affected: %d\n", sth.rows
  else
    puts "Statement has a result set"
    rows = sth.fetch_all
    printf "Number of rows: %d\n", rows.size
    printf "Number of columns: %d\n", sth.column_names.size
    sth.column_info.each_with_index do |info, i|
      printf "--- Column %d (%s) ---\n", i, info["name"]
      printf "sql_type:         %s\n", info["sql_type"]
      printf "type_name:        %s\n", info["type_name"]
      printf "precision:        %s\n", info["precision"]
      printf "scale:            %s\n", info["scale"]
      printf "nullable:         %s\n", info["nullable"]
      printf "indexed:          %s\n", info["indexed"]
      printf "primary:          %s\n", info["primary"]
      printf "unique:           %s\n", info["unique"]
      printf "mysql_type:       %s\n", info["mysql_type"]
      printf "mysql_type_name:  %s\n", info["mysql_type_name"]
      printf "mysql_length:     %s\n", info["mysql_length"]
      printf "mysql_max_length: %s\n", info["mysql_max_length"]
      printf "mysql_flags:      %s\n", info["mysql_flags"]
    end
  end
  sth.finish
#@ _METADATA_

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

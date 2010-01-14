#!/usr/bin/ruby -w
# fields.rb - try list_fields method

require "mysql"

begin
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")

  puts "Columns in animal table:"
  res = dbh.list_fields("animal")
  res.fetch_fields.each do |col_info|
    puts "name: " + col_info.name
  end
  res.free

rescue Mysql::Error => e
  puts "An error occurred"
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  dbh.close if dbh
end

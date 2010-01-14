#!/usr/bin/ruby -w
# special.rb - demonstrate special value handling:
# - detecting NULL values in result sets
# - inserting values containing quotes or other special characters
#   as data values in queries

require "mysql"

begin
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")

  # create the animal table and populate it
  dbh.query("DROP TABLE IF EXISTS animal")
  dbh.query("CREATE TABLE animal
             (
               name CHAR(40),
               category CHAR(40)
             )
           ")
  dbh.query("INSERT INTO animal (name, category)
               VALUES
                 ('snake', 'reptile'),
                 ('frog', 'amphibian'),
                 ('tuna', 'fish'),
                 ('racoon', 'mammal')
             ")
  puts "Number of rows inserted: #{dbh.affected_rows}"

  # insert some NULL values into the table, so that there are some :-)
#@ _INSERT_NULL_
  dbh.query("INSERT INTO animal (name, category) VALUES (NULL, NULL)")
#@ _INSERT_NULL_

  # fetch and print, no special handling
  puts "print values with no special handling (no NULL detection)"
#@ _EACH_LOOP_1_
  res = dbh.query("SELECT name, category FROM animal")

  res.each do |row|
    printf "%s, %s\n", row[0], row[1]
  end

  res.free
#@ _EACH_LOOP_1_

  # fetch and print, with NULL (represented by nil) detection
  res = dbh.query("SELECT name, category FROM animal")

  puts "print values, detecting NULL with per-column tests"
#@ _EACH_LOOP_2_
  res.each do |row|
    row[0] = "NULL" if row[0].nil?
    row[1] = "NULL" if row[1].nil?
    printf "%s, %s\n", row[0], row[1]
  end
#@ _EACH_LOOP_2_

  # rewind result set by seeking to row 0
  res.data_seek(0)
  puts "print values, detecting NULL with collect"
#@ _EACH_LOOP_3_
  res.each do |row|
    row = row.collect { |v| v.nil? ? "NULL" : v }
    printf "%s, %s\n", row[0], row[1]
  end
#@ _EACH_LOOP_3_

  res.data_seek(0)
  puts "print values, detecting NULL with collect!"
#@ _EACH_LOOP_4_
  res.each do |row|
    row.collect! { |v| v.nil? ? "NULL" : v }
    printf "%s, %s\n", row[0], row[1]
  end
#@ _EACH_LOOP_4_

  res.free

  # Use escape_string to handle escaping of special characters in
  # data values

#@ _ESCAPE_STRING_
  name = dbh.escape_string("platypus")
  category = dbh.escape_string("don't know")
  dbh.query("INSERT INTO animal (name, category)
             VALUES ('" + name + "','" + category + "')")
#@ _ESCAPE_STRING_

  # display result to make sure it's okay:
  res = dbh.query("SELECT name, category
                   FROM animal WHERE name = 'platypus'")

  res.each do |row|
    printf "%s, %s\n", row[0], row[1]
  end

  res.free

rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  dbh.close if dbh
end

#!/usr/bin/ruby -w
# animal.rb - create animal table and
# retrieve information from it

require "mysql"

begin
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")
rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  exit(1)
end

# create the animal table and populate it
#@ _INITIALIZE_TABLE_
dbh.query("DROP TABLE IF EXISTS animal")
dbh.query("CREATE TABLE animal
           (
             name     CHAR(40),
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
#@ _INITIALIZE_TABLE_

puts "Retrieve using fetch_row"
#@ _FETCH_ROW_LOOP_
# issue a retrieval query, perform a fetch loop, print
# the row count, and free the result set

res = dbh.query("SELECT name, category FROM animal")

while row = res.fetch_row do
  printf "%s, %s\n", row[0], row[1]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _FETCH_ROW_LOOP_

# perform a fetch loop using fetch_hash

puts "Retrieve using fetch_hash"
#@ _FETCH_HASH_LOOP_
res = dbh.query("SELECT name, category FROM animal")

while row = res.fetch_hash do
  printf "%s, %s\n", row["name"], row["category"]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _FETCH_HASH_LOOP_

# perform a fetch loop using the each iterator

puts "Retrieve using each"
#@ _EACH_LOOP_
res = dbh.query("SELECT name, category FROM animal")

res.each do |row|
  printf "%s, %s\n", row[0], row[1]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _EACH_LOOP_

# perform a fetch loop using the each_hash iterator

puts "Retrieve using each_hash"
#@ _EACH_HASH_LOOP_1_
res = dbh.query("SELECT name, category FROM animal")

res.each_hash do |row|
  printf "%s, %s\n", row["name"], row["category"]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _EACH_HASH_LOOP_1_

#@ _EACH_HASH_LOOP_2_
res = dbh.query("SELECT name, category FROM animal")

res.each_hash(with_table = true) do |row|
  printf "%s, %s\n", row["animal.name"], row["animal.category"]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _EACH_HASH_LOOP_2_

puts "Retrieve using use_result and fetch_row"
#@ _QUERY_WITH_RESULT_
dbh.query_with_result = false
#@ _QUERY_WITH_RESULT_
#@ _USE_RESULT_
dbh.query("SELECT name, category FROM animal")
res = dbh.use_result

while row = res.fetch_row do
  printf "%s, %s\n", row[0], row[1]
end
puts "Number of rows returned: #{res.num_rows}"

res.free
#@ _USE_RESULT_

dbh.close

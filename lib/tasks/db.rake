require 'Bootstrap'
begin
  require "faster_csv"
  FasterCSV.build_csv_interface
rescue LoadError
  require "csv"
end

namespace :db do
  namespace :bootstrap do
    namespace :panda do
      desc 'Bootstrap Panda DB'
      task :all => :environment do
        Bootstrap.all
      end

      desc 'Bootstrap Panda DB:lookups table'
      task :lookups do
        Bootstrap.lookups
      end
    end
  end

  namespace :indexes do
    desc "Prints a list of unindexed foreign keys so you can index them"
    task :missing => :environment do
      indexes = {}
      conn = ActiveRecord::Base.connection
      conn.tables.each do |table|
        indexed_columns = conn.indexes(table).map { |i| i.columns }.flatten
        conn.columns(table).each do |column|
          if column.name.match(/_id/) && !indexed_columns.include?(column.name)
            indexes[table] ||= []
            indexes[table] << column.name
          end
        end
      end
      puts "Foreign Keys:"
      indexes.each do |table, columns|
        puts columns.map { |c| "\s\sadd_index '#{table}', '#{c}'\n"}
      end
    end
  end

  desc 'Print data size for entire database'
  task :size => :environment do

    database_name = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
    adapter = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter
      when "mysql"
        sql = "select FORMAT(SUM(data_length + index_length), 0) as bytes from information_schema.TABLES where table_schema = '#{database_name}'"
        puts ActiveRecord::Base.connection.execute(sql).fetch_hash.values.first
      when "postgres", "postgresql"
        sql = "SELECT pg_size_pretty(pg_database_size('#{database_name}'));"
        puts ActiveRecord::Base.connection.execute(sql)[0]["pg_size_pretty"]
      when "oracle", "oci"
        sql = "select a.data_size+b.temp_size+c.redo_size+d.controlfile_size  from ( select sum(bytes) data_size from dba_data_files) a, ( select nvl(sum(bytes),0) temp_size from dba_temp_files ) b, ( select sum(bytes) redo_size from sys.v_$log ) c, ( select sum(BLOCK_SIZE*FILE_SIZE_BLKS) controlfile_size from v$controlfile) d;"
        puts ActiveRecord::Base.connection.execute(sql).fetch_hash.values.first
      else
        raise "#{adapter} is not supported"
    end
  end

  namespace :tables do
    desc 'Print data size for all tables'
    task :size => :environment do

      database_name = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
      adapter = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter
        when "mysql"
          sql = "select TABLE_NAME, FORMAT((data_length + index_length), 0) as bytes from information_schema.TABLES where table_schema = '#{database_name}' ORDER BY (data_length + index_length) DESC"
          result = ActiveRecord::Base.connection.execute(sql)
          while (row = result.fetch_hash) do
            puts "#{row['TABLE_NAME']} #{row['bytes']}"
          end
        when "postgres", "postgresql"
          sql = "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
          tables = ActiveRecord::Base.connection.execute(sql)
          tables.each do |table|
            name = table['tablename']
            sql = "SELECT pg_size_pretty(pg_total_relation_size('#{name}'));"
            res = ActiveRecord::Base.connection.execute(sql)
            puts "#{name} #{res[0]['pg_size_pretty']}"
          end
        else
          raise "#{adapter} is not supported"
      end
    end
  end
end
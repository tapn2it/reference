require File.dirname(__FILE__) + '/../db_migration'
include DbMigration

namespace :mysql do
  namespace :table do
    desc 'load states table'
    task :states => :setup do
      sql = %Q(USE #{@new_db};)
      puts sql
      ActiveRecord::Base.connection.execute sql

      sql = %Q(DROP TABLE IF EXISTS #{@new_db}.states;)
      puts sql
      ActiveRecord::Base.connection.execute sql

      sql = %Q(CREATE TABLE #{@new_db}.states (
        state_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        state_name VARCHAR(32) NOT NULL,
        state_abbr VARCHAR(8));)
      puts sql
      ActiveRecord::Base.connection.execute sql

      sql = %Q(INSERT #{@new_db}.states VALUES
        (NULL, 'Alabama', 'AL'),
        (NULL, 'Alaska', 'AK'),
        (NULL, 'Arizona', 'AZ'),
        (NULL, 'Arkansas', 'AR'),
        (NULL, 'California', 'CA'),
        (NULL, 'Colorado', 'CO'),
        (NULL, 'Connecticut', 'CT'),
        (NULL, 'Delaware', 'DE'),
        (NULL, 'District of Columbia', 'DC'),
        (NULL, 'Florida', 'FL'),
        (NULL, 'Georgia', 'GA'),
        (NULL, 'Hawaii', 'HI'),
        (NULL, 'Idaho', 'ID'),
        (NULL, 'Illinois', 'IL'),
        (NULL, 'Indiana', 'IN'),
        (NULL, 'Iowa', 'IA'),
        (NULL, 'Kansas', 'KS'),
        (NULL, 'Kentucky', 'KY'),
        (NULL, 'Louisiana', 'LA'),
        (NULL, 'Maine', 'ME'),
        (NULL, 'Maryland', 'MD'),
        (NULL, 'Massachusetts', 'MA'),
        (NULL, 'Michigan', 'MI'),
        (NULL, 'Minnesota', 'MN'),
        (NULL, 'Mississippi', 'MS'),
        (NULL, 'Missouri', 'MO'),
        (NULL, 'Montana', 'MT'),
        (NULL, 'Nebraska', 'NE'),
        (NULL, 'Nevada', 'NV'),
        (NULL, 'New Hampshire', 'NH'),
        (NULL, 'New Jersey', 'NJ'),
        (NULL, 'New Mexico', 'NM'),
        (NULL, 'New York', 'NY'),
        (NULL, 'North Carolina', 'NC'),
        (NULL, 'North Dakota', 'ND'),
        (NULL, 'Ohio', 'OH'),
        (NULL, 'Oklahoma', 'OK'),
        (NULL, 'Oregon', 'OR'),
        (NULL, 'Pennsylvania', 'PA'),
        (NULL, 'Rhode Island', 'RI'),
        (NULL, 'South Carolina', 'SC'),
        (NULL, 'South Dakota', 'SD'),
        (NULL, 'Tennessee', 'TN'),
        (NULL, 'Texas', 'TX'),
        (NULL, 'Utah', 'UT'),
        (NULL, 'Vermont', 'VT'),
        (NULL, 'Virginia', 'VA'),
        (NULL, 'Washington', 'WA'),
        (NULL, 'West Virginia', 'WV'),
        (NULL, 'Wisconsin', 'WI'),
        (NULL, 'Wyoming', 'WY')
        ;)
      puts sql
      ActiveRecord::Base.connection.execute sql
    end


    namespace :function do
      desc "at mysql prompt enter sql in load_cap_first_function. Do this each mysql server."
      task :load_cap_first_function => :setup do
        # change database_name below to actual database
        dbs = ['sportsnation_migration', "fanprofiles_production"]
        dbs.each do |database|
          puts "Drop procedure #{database}..."
          ActiveRecord::Base.connection.execute %Q(DROP FUNCTION IF EXISTS sportsnation_migration.CAP_FIRST)
          sql = %Q(
            CREATE FUNCTION #{database}.CAP_FIRST (input VARCHAR(255))
            RETURNS VARCHAR(255)
            DETERMINISTIC

            BEGIN
            DECLARE len INT;
            DECLARE i INT;

            SET len   = CHAR_LENGTH(input);
            SET input = lower(input);
            SET i = 0;

            WHILE (i < len) DO
              IF (MID(input,i,1) = ' ' OR i = 0) THEN
                IF (i < len) THEN
                  SET input = CONCAT(
                    LEFT(input,i),
                    UPPER(MID(input,i + 1,1)),
                    RIGHT(input,len - i - 1)
                    );
                END IF;
              END IF;
              SET i = i + 1;
            END WHILE;

            RETURN input;
            END;
        )
          puts "Create function in #{database}..."
          ActiveRecord::Base.connection.execute sql
        end
      end

      desc "Drop/create stored procedure set auto_increment value "
      task :create_auto_increment_proc do
        database = 'sportsnation_#{Rails.env}'
        puts "Drop procedure in #{database}..."
        ActiveRecord::Base.connection.execute %Q(DROP PROCEDURE IF EXISTS sportsnation_migration.SET_AUTO_INCREMENT)
        sql = %Q(
              CREATE PROCEDURE #{database}.SET_AUTO_INCREMENT(tbl VARCHAR(30), fld VARCHAR(30))
              BEGIN
                SET @vSQL = CONCAT("SELECT MAX(", fld, ") + 1 INTO @AUTO_INCR_VALUE FROM ", tbl);
                PREPARE stmt1 FROM @vSQL;
                EXECUTE stmt1;
                DEALLOCATE PREPARE stmt1;
                SET @vSQL = CONCAT("ALTER TABLE ", tbl, " AUTO_INCREMENT = ", @AUTO_INCR_VALUE);
                PREPARE stmt1 FROM @vSQL;
                EXECUTE stmt1;
                DEALLOCATE PREPARE stmt1;
              END;
      )

        #system %Q(mysql -uroot --delimiter='$$' --database='sportsnation_migration' --execute='#{sql}')
        puts "Create procedure in #{database}..."
        ActiveRecord::Base.connection.execute sql
      end

      desc "Remove html tags from table attribute"
      task :remove_html_proc do
        database = 'database_#{Rails.env}'
        puts "Drop procedure in #{database}..."
        ActiveRecord::Base.connection.execute %Q(DROP PROCEDURE IF EXISTS #{database}.REMOVE_HTML)
        sql = %Q(
                CREATE FUNCTION 'REMOVE_HTML(strText longtext)
                RETURNS longtext

                BEGIN
                  DECLARE nPos1, nPos2 int;
                  SET nPos1 =INSTR(strText, "<");
                  WHILE nPos1 > 0 DO
                    SET nPos2 = locate( ">", strText, nPos1 + 1);
                    IF nPos2 > 0 THEN
                      SET strText = CONCAT(Left(strText, nPos1 - 1), MID(strText, nPos2 + 1));
                    END IF;
                    SET nPos1 = INSTR(strText, "<");
                  END WHILE;
                  RETURN strText;
                END;
      )

        puts "Create procedure in #{database}..."
        ActiveRecord::Base.connection.execute sql
      end
    end

    desc "reset autoincrement to max id plus one for all tables with autoincrement"
    task :reset_autoincrement => :setup do
      puts "\n\nreset autoincrement on sportsnation_#{Rails.env}..."
      connection = ActiveRecord::Base.connection
      connection.execute "USE sportsnation_#{Rails.env};"
      results = connection.execute "SELECT table_name FROM information_schema.tables WHERE table_schema = 'sportsnation_migration' AND auto_increment IS NOT NULL;"
      results.each do |table|
        count = connection.execute "CALL SET_AUTO_INCREMENT(#{table}, 'id');"
        puts " #{table}   (row count: #{count.fetch_row[0]})"
      end
    end

    desc "rename sportsnation_production tables into sportsnation_backup"
    task :rename_to_backup => :setup do
      puts "\n\nrename sportsnation_production tables into sportsnation_backup"
      connection = ActiveRecord::Base.connection
      connection.execute "USE sportsnation_#{Rails.env};"
      results = connection.execute "SELECT table_name FROM information_schema.tables WHERE table_schema = 'sportsnation_production';"
      results.each do |table|
        count = connection.execute "RENAME TABLE sportsnation_production.#{table} TO sportsnation_backup.#{table};"
        puts "   renaming #{table}..."
      end
    end

    desc "rename sportsnation_migration tables into sportsnation_production"
    task :rename_to_production => :setup do
      puts "\n\nrename sportsnation_migration tables into sportsnation_production"
      connection = ActiveRecord::Base.connection
      connection.execute "USE sportsnation_#{Rails.env};"
      results = connection.execute "SELECT table_name FROM information_schema.tables WHERE table_schema = 'sportsnation_migration';"
      results.each do |table|
        count = connection.execute "RENAME TABLE sportsnation_migration.#{table} TO sportsnation_#{Rails.env}.#{table};"
        puts "   renaming #{table}..."
      end
    end

    desc "get database stats for migrations"
    task :stats do
      show_table_counts connect_to_fanprofiles_production
      show_table_counts connect_to_sportsnation_production
      show_table_counts connect_to_sportsnation_migration
    end

    task :setup => :environment do
      migration_setup
    end
  end
end

def show_table_counts(connection)
  puts "\n\ndb: #{connection_info connection, :database}"
  connection.execute "USE #{connection_info connection, :database};"
  results = connection.execute "SHOW TABLES;"
  results.each do |table|
    count = connection.execute "SELECT COUNT(*) FROM #{table};"
    puts " #{table}   (row count: #{count.fetch_row[0]})"
  end
end
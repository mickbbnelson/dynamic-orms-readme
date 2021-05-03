require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")}   #Creates the database
DB[:conn].execute("DROP TABLE IF EXISTS songs")   #Drops any existing songs table if there happens to be one

sql = <<-SQL                                
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL
                                        #^Creates table in database
DB[:conn].execute(sql)
DB[:conn].results_as_hash = true        #results_as_hash is a method provided to us by the sqlite3-ruby-gem.
                                        #This method says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.
require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name               #takes the name of the class, referenced by the self keyword, turns it to a string, downcases and pluralizes
    self.to_s.downcase.pluralize    #gem needed for the pluralize method
  end

  def self.column_names
    DB[:conn].results_as_hash = true    #This method says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.

    sql = "pragma table_info('#{table_name}')"      #querys a table for the names of its columns

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]     #We iterate over the resulting array of hashes to collect just the name of each column.
    end                                #The return value of calling Song.column_names will therefore be:["id", "name", "album"]
    column_names.compact
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym         #tells the class that it should have attr_accessors named after each column name
  end

  def initialize(options={})    #We iterate over the options hash and use our fancy metaprogramming #send method to interpolate the name of each hash key as a method that we set equal to that key's value.
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name       #access the table name we want to INSERT into from inside our #save method,
  end

  def values_for_insert         #iterate over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")  #Delets the column name if it = id
  end

  def self.find_by_name(name)  #it uses the #table_name class method we built that will return the table name associated with any given class.
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end




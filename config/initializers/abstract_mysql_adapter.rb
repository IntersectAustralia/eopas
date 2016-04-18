# config/initializers/abstract_mysql_adapter.rb
class ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY NOT NULL"
end

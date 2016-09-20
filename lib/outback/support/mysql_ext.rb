module Outback
  module MysqlExt
    module Mysql
      def databases
        result = query('SHOW DATABASES')
        databases = result.fetch_all_rows.flatten
        result.free
        databases
      end
    end
    
    module Result
      def fetch_all_rows
        returning [] do |rows|
          each { |row| rows << row }
        end
      end
    end
  end
end

Mysql.send :include, Outback::MysqlExt::Mysql
Mysql::Result.send :include, Outback::MysqlExt::Result
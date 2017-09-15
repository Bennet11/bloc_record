require 'bloc_record/utility'
require 'bloc_record/schema'
require 'bloc_record/persistence'
require 'bloc_record/selection'
require 'bloc_record/connection'
require 'bloc_record/collection'
require 'bloc_record/associations'

module BlocRecord
  class Base
    include Persistence
    extend Selection
    extend Schema
    extend Connection
    extend Associations

    def initialize(options={})
      options = BlocRecord::Utility.convert_keys(options)

      self.class.columns.each do |col|
        self.class.send(:attr_accessor, col)
        self.instance_variable_set("@#{col}", options[col])
      end
    end

    def self.execute(sql)
      if BlocRecord.database_type == :sqlite3
        self.connection.execute(sql)
      elsif BlocRecord.database_type == :pg
        self.connection.exec(sql)
      end
    end
  end
end

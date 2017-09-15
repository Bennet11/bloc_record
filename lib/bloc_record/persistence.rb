require 'sqlite3'
require 'bloc_record/schema'

module Persistence

  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{self.id};
    SQL

    true
  end

  def update_attribute(attribute, value)
    self.class.update(self.id, { attribute => value} )
  end

  def update_attributes(updates)
    self.class.update(self.id, updates)
  end

  def destroy
    self.class.destroy(self.id)
  end

  module ClassMethods

    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete "id"
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ","})
        VALUES (#{vals.join ","});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
    end

    def update(ids, updates)
      case updates
      when Hash
        updates = BlocRecord::Utility.convert_keys(updates)
        updates.delete "id"

        updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

        if ids.class == Fixnum
          where_clause = "WHERE id = #{ids};"
        elsif ids.class == Array
          where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
        else
          where_clause = ";"
        end

        connection.execute <<-SQL
          UPDATE #{table}
          SET #{updates_array * ","} #{where_clause}
        SQL

        true
      when Array
        updates.each_with_index do |data, index|
          update(ids[index], data)
        end
      end
    end

    def update_all(update)
      update(nil, updates)
    end

    def destroy(*id)
      if id.length > 1
        where_clause = "WHERE id IN (#{id.join(",")});"
      else
        where_clause = "WHERE id = #{id.first};"
      end


      connection.execute <<-SQL
        DELETE FROM #{table} #{where_clause}
      SQL

      true
    end

#  Entry.destroy_all("phone_number = '999-999-9999'")
#  Entry.destroy_all("phone_number = ?", '999-999-9999')

    def destroy_all(conditions_hash=nil)
      if conditions_hash && !conditions_hash.empty?
        case conditions_hash
        when Hash
          conditions_hash = BlocRecord::Utility.convert_keys(conditions_hash)
          conditions = conditions_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
        when String
          conditions = conditions_hash
        when Array
          conditions = conditions_hash.join(",")
        end
        connection.execute <<-SQL
          DELETE FROM #{table}
          WHERE #{conditions}
        SQL
      else
        connection.execute <<-SQL
          DELETE FROM #{table}
        SQL
      end
      true
    end

    def method_missing(method, *args, &block)
      if method.include? "update"
        m = method.select { |key, value| arg.include(key) }
        self.delete_if { |key, value| arg.include(key) }
      end
      update(m, arg[0])
    end


    #   def method_missing(method, *args, &block)
    #     if m.include? "update" # check to see if the method name includes "update"
    #       # extract the second part of method (the part after "e_") and assign it to a variable
    #       # indexOf might be useful for this
    #     update(m, args[0]) # call the update method with the extracted string and the first arg
    #   end

    # def method_missing(methId, *args)
    #   attribute = methId.to_s
    #   if columns.include?(attribute)
    #     find_by(attribute, *args)
    #   else
    #     puts "There's no item called #{attribute} here -- please try again."
    #   end
    #   method_missing(methId, *args)
    # end
  end
end

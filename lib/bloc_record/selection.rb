require 'sqlite3'

module Selection

  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE id = #{id};
     SQL

     init_object_from_row(row)
  end

  def find_by(attribute, value)
    row = connection.execute <<-SQL
      SELECT #{attribute} FROM #{table}
      WHERE #{value} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)
  end

  def find_each(hash)
    row = connection.execute <<-SQL
      SELECT * FROM #{table}
      ORDER BY #{table}.id
      LIMIT #{batchsize}
    SQL

    current_row_index = 0
    while current_row_index <= row.length - 1
      yield
      current_row_index += 1
    end
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num}
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)

  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
    SQL

    rows_to_array(rows)
  end

  private
  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def method_missing(m, *args, &block)

  end

  def rows_to_array(row)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end
end

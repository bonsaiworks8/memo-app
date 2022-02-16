# frozen_string_literal: true

require 'pg'

class MemoPgDB
  def initialize
    @db_connect = PG.connect host: 'localhost', user: 'postgres', dbname: 'memo_app'
  end

  def all
    result = @db_connect.exec('select * from memos')

    result.map do |row|
      { id: row['id'], title: row['title'], body: row['body'] }
    end
  end

  def save(title, body)
    @db_connect.exec("INSERT INTO memos(title, body) VALUES ('#{escape_str(title)}', '#{escape_str(body)}')")
    true
  end

  def find(id)
    result = @db_connect.exec("SELECT * FROM memos WHERE id = #{escape_str(id.to_s)}")

    record = nil
    result.each do |row|
      record = { id: row['id'], title: row['title'], body: row['body'] }
    end
    record
  end

  def update(id, title, body)
    return false if find(id).nil?

    @db_connect.exec("UPDATE memos SET title = '#{escape_str(title)}', body = '#{escape_str(body)}' WHERE id = #{escape_str(id.to_s)}")
    true
  end

  def destroy(id)
    return false if find(id).nil?

    @db_connect.exec("DELETE FROM memos WHERE id = #{escape_str(id.to_s)}")
    true
  end

  def close
    @db_connect.finish
  end

  private

  def escape_str(str)
    PG::Connection.escape_string str
  end
end

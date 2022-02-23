# frozen_string_literal: true

require 'pg'

class MemoPgDB
  def initialize
    @db_connect = PG.connect host: 'localhost', user: 'postgres', dbname: 'memo_app'
  end

  def all
    result = @db_connect.exec('SELECT * FROM memos')

    result.map do |row|
      { id: row['id'], title: row['title'], body: row['body'] }
    end
  end

  def save(_title, body)
    query = 'INSERT INTO memos(title, body) VALUES ($1, $2)'
    prepare_name = 'save'
    begin
      exec_prepared query, prepare_name, [titile, body]
    rescue StandardError
      true
    end
    true
  end

  def find(id)
    query = 'SELECT * FROM memos WHERE id = $1'
    prepare_name = 'find'
    result = exec_prepared query, prepare_name, [id]

    record = nil
    result.each do |row|
      record = { id: row['id'], title: row['title'], body: row['body'] }
    end
    record
  end

  def update(id, _title, body)
    return false if find(id).nil?

    query = 'UPDATE memos SET title = $2, body = $3 WHERE id = $1'
    prepare_name = 'update'
    begin
      exec_prepared query, prepare_name, [id, titile, body]
    rescue StandardError
      true
    end
    true
  end

  def destroy(id)
    return false if find(id).nil?

    query = 'DELETE FROM memos WHERE id = $1'
    prepare_name = 'destroy'
    exec_prepared query, prepare_name, [id]
    true
  end

  def close
    @db_connect.finish
  end

  private

  def exec_prepared(query, prepare_name, parameters)
    @db_connect.prepare(prepare_name, query)
    @db_connect.exec_prepared(prepare_name, parameters)
  end
end

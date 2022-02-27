# frozen_string_literal: true

require 'pg'

class MemoPgDB
  def initialize
    @connection = PG.connect host: 'localhost', user: 'postgres', dbname: 'memo_app'
  end

  def all
    result = @connection.exec('SELECT * FROM memos ORDER BY id ASC')

    result.map do |row|
      { id: row['id'], title: row['title'], body: row['body'] }
    end
  end

  def save(title, body)
    query = 'INSERT INTO memos(title, body) VALUES ($1, $2)'
    prepare_name = 'save'

    exec_prepared query, prepare_name, [title, body]
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

  def update(id, title, body)
    return false if find(id).nil?

    query = 'UPDATE memos SET title = $2, body = $3 WHERE id = $1'
    prepare_name = 'update'

    exec_prepared query, prepare_name, [id, title, body]
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
    @connection.finish
  end

  private

  def exec_prepared(query, prepare_name, parameters)
    @connection.prepare(prepare_name, query)
    @connection.exec_prepared(prepare_name, parameters)
  end
end

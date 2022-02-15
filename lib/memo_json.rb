# frozen_string_literal: true

require_relative './memo_generic'
require 'json'

class MemoJson < MemoGeneric
  DATA_FILE_PATH = 'memos.json'

  def all
    read_file DATA_FILE_PATH
  end

  def find(id)
    records = read_file DATA_FILE_PATH

    records.find { |record| record[:id].to_i == id.to_i }
  end

  def save(title, body)
    records = read_file DATA_FILE_PATH

    id_list = records.map { |record| record[:id].to_i }
    push_id = id_list.empty? ? 1 : id_list.max + 1
    records.push({ id: push_id.to_s, title: title.to_s, body: body.to_s })

    write_file DATA_FILE_PATH, records
  end

  def update(id, title, body)
    records = read_file DATA_FILE_PATH

    is_completed = false
    records.each_with_index do |record, i|
      next unless record[:id].to_i == id.to_i

      records[i] = { id: id.to_s, title: title.to_s, body: body.to_s }
      is_completed = write_file DATA_FILE_PATH, records
      break
    end

    is_completed
  end

  def destroy(id)
    records = read_file DATA_FILE_PATH

    is_completed = false
    records.each do |record|
      next unless record[:id].to_i == id.to_i

      records.delete(record)
      is_completed = write_file DATA_FILE_PATH, records
      break
    end

    is_completed
  end

  private

  def read_file(path)
    write_file path, [] unless File.exist? path

    File.open(path, 'r') do |file|
      JSON.parse file.read, symbolize_names: true
    end
  end

  def write_file(path, hash)
    File.open(path, 'a') do |file|
      raise StandardError unless file.flock(File::LOCK_EX | File::LOCK_NB)

      file.truncate 0
      JSON.dump hash, file
      true
    end
  end
end

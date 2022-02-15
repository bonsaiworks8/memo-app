# frozen_string_literal: true

require_relative './memo_generic'

class MemoMock < MemoGeneric
  @records =
    [
      { id: '1', title: '今日の天気', body: '晴れ' },
      { id: '2', title: '今日の夕飯の献立', body: 'ハンバーグとポテトサラダとお味噌汁' }
    ]

  def all
    @records
  end

  def find(id)
    @records.each do |record|
      return record if record[:id].to_i == id.to_i
    end

    nil
  end

  def save(title, body)
    push_id = 0
    @@records.each do |record|
      id = record[:id].to_i
      push_id = id if id > push_id
    end
    push_id += 1

    @records.push({ id: push_id.to_s, title: title.to_s, body: body.to_s })
    true
  end

  def update(id, title, body)
    @records.each_with_index do |record, i|
      if record[:id].to_i == id.to_i
        @records[i] = { id: id.to_s, title: title.to_s, body: body.to_s }
        return true
      end
    end

    false
  end

  def destroy(id)
    @records.each do |record|
      if record[:id].to_i == id.to_i
        @records.delete(record)
        return true
      end
    end

    false
  end
end

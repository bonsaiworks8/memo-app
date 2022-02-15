# frozen_string_literal: true

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class AppTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    initialize_memo_file

    Sinatra::Application
  end

  def test_get_not_exist_url
    get '/not-exist-url'
    assert_equal 404, last_response.status
  end

  def test_get
    ['/', '/memos', '/memos/show/1', '/memos/new', '/memos/edit/1', '/memos/delete/1'].each_with_index do |uri, i|
      get uri

      assert last_response.ok?
      if i <= 1
        assert last_response.body.include? '今日の夕飯の献立'
        assert last_response.body.include? '2022年2月7日の天気'
      elsif i == 2
        assert last_response.body.include? 'メモの詳細'
        assert_include_content1
      elsif i == 3
        assert last_response.body.include? 'メモの登録'
      elsif i == 4
        assert last_response.body.include? 'メモの編集'
        assert_include_content1
      else
        assert last_response.body.include? 'メモの削除'
        assert_include_content1
      end
    end
  end

  def test_post_new
    post '/memos', { title: '2022年2月8日の天気', body: '雨' }
    assert_equal 303, last_response.status
  end

  def test_post_new_empty
    post '/memos', { title: nil, body: nil }
    assert_equal 500, last_response.status
  end

  def test_post_edit
    patch '/memos/1', title: '今日の夕飯の献立', body: "・カツカレー\r\n・サラダ"
    assert_equal 303, last_response.status
  end

  def test_post_edit_not_exist
    patch '/memos/99', id: '99', title: 'ありません', body: 'ありません'
    assert_equal 404, last_response.status
  end

  def test_post_delete
    delete '/memos/1'
    assert_equal 303, last_response.status
  end

  def test_post_delete_not_exist
    delete '/memos/99'
    assert_equal 404, last_response.status
  end

  def test_exclusive_post_new
    lock_data_file

    post '/memos', title: '2022年2月8日の天気', body: '雨'
    assert_equal 200, last_response.status
    assert last_response.body.include? MemoGeneric::SAVE_FAILURE
  end

  def test_exclusive_post_edit
    lock_data_file

    patch '/memos/1', title: '今日の夕飯の献立', body: "・カツカレー\r\n・サラダ"
    assert_equal 200, last_response.status
    assert last_response.body.include? MemoGeneric::SAVE_FAILURE
  end

  def test_exclusive_post_delete
    lock_data_file

    delete '/memos/1'
    assert_equal 200, last_response.status
    assert last_response.body.include? MemoGeneric::DELETE_FAILURE
  end

  private

  def initialize_memo_file
    path = MemoJson::DATA_FILE_PATH
    records =
      [
        { "id": '1', "title": '今日の夕飯の献立', "body": "・ハンバーグ\r\n・サラダ\r\n・お味噌汁" },
        { "id": '2', "title": '2022年2月7日の天気', "body": '晴れ' }
      ]

    File.open(path, 'a') do |file|
      if file.flock(File::LOCK_EX)
        file.truncate 0
        JSON.dump records, file
      end
    end
  end

  def lock_data_file
    Thread.new do
      File.open(MemoJson::DATA_FILE_PATH, 'a') do |file|
        sleep 1 if file.flock(File::LOCK_EX)
      end
    end
  end

  def assert_include_content1
    assert last_response.body.include? '今日の夕飯の献立'
    assert last_response.body.include? "・ハンバーグ\r\n・サラダ\r\n・お味噌汁"
  end
end

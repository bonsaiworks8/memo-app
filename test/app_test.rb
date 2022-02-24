# frozen_string_literal: true

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
require 'pg'

ENV['RACK_ENV'] = 'test'

class AppTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    initialize_memo_db

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
    patch '/memos/2', title: '2022年2月7日の天気', body: '雨'
    assert_equal 303, last_response.status
  end

  def test_post_edit_not_exist
    patch '/memos/99', id: '99', title: 'ありません', body: 'ありません'
    assert_equal 404, last_response.status
  end

  def test_post_delete
    delete '/memos/3'
    assert_equal 303, last_response.status
  end

  def test_post_delete_not_exist
    delete '/memos/99'
    assert_equal 404, last_response.status
  end

  private

  def assert_include_content1
    assert last_response.body.include? '今日の夕飯の献立'
    assert last_response.body.include? "・ハンバーグ\n・サラダ\n・お味噌汁"
  end

  def initialize_memo_db
    db_connect = PG.connect host: 'localhost', user: 'postgres', dbname: 'memo_app'
    db_connect.exec('drop table if exists memos')
    db_connect.exec('create table memos (id serial, title text, body text, primary key (id))')
    db_connect.exec("insert into memos(title, body) values ('今日の夕飯の献立', E'・ハンバーグ\n・サラダ\n・お味噌汁')")
    db_connect.exec("insert into memos(title, body) values ('2022年2月7日の天気', '晴れ')")
    db_connect.exec("insert into memos(title, body) values ('2022年2月7日の運勢', '大吉')")
    db_connect.finish
  end
end

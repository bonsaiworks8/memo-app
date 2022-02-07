# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

# require_relative "./lib/memo_generic"
# require_relative "./lib/memo_mock"
require_relative './lib/memo_json'

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end

  def empty?(title, body)
    result = title.empty? || body.empty?
    session[:error] = MemoGeneric::BLANK_ERROR if result
    result
  end
end

configure do
  enable :sessions
end

before do
  @memo_model = MemoJson.new
end

before '/memos/:action/:id' do
  memo = @memo_model.find params[:id].to_i
  @title = memo[:title]
  @body = memo[:body]

  @id = params[:id].to_i if params[:action] != 'show'
end

before '/memos/:id' do
  @id = params[:id]
  @title = params[:title]
  @body = params[:body]
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  body = params[:body]

  if empty? title, body
    @title = title
    @body = body
    erb :new
  else
    begin
      if @memo_model.save title, body
        session[:notify] = MemoGeneric::SAVE_COMPLETED
        redirect to('/memos'), 303
      end
    rescue StandardError
      session[:error] = MemoGeneric::SAVE_FAILURE
      @title = title
      @body = body
      erb :new
    end
  end
end

['/', '/memos'].each do |uri|
  get uri do
    @memos = @memo_model.all
    erb :index
  end
end

get '/memos/show/:id' do
  erb :show
end

get '/memos/edit/:id' do
  erb :edit
end

patch '/memos/:id' do
  if empty? @title, @body
    erb :edit
  else
    begin
      if @memo_model.update @id.to_i, @title, @body
        session[:notify] = MemoGeneric::SAVE_COMPLETED
        redirect to('/memos'), 303
      else
        not_found
      end
    rescue StandardError
      session[:error] = MemoGeneric::SAVE_FAILURE
      erb :edit
    end
  end
end

get '/memos/delete/:id' do
  erb :delete
end

delete '/memos/:id' do
  if @memo_model.destroy @id.to_i
    session[:notify] = MemoGeneric::DELETE_COMPLETED
    redirect to('/memos'), 303
  else
    not_found
  end
rescue StandardError
  session[:error] = MemoGeneric::DELETE_FAILURE
  memo = @memo_model.find params[:id].to_i
  @title = memo[:title]
  @body = memo[:body]
  erb :delete
end

not_found do
  '404 Not Found.<br>そのようなページはございません。'
end

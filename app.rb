# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

require_relative './lib/memo_generic'
require_relative './lib/memo_pgdb'

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

configure do
  enable :sessions
end

before do
  @memo_manipulator = MemoPgDB.new
end

after do
  @memo_manipulator.close
end

before '/memos/:action/:id' do
  @memo = @memo_manipulator.find params[:id].to_i
end

before ['/memos/:id', '/memos'] do
  @memo = params.slice(:id, :title, :body)
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  if MemoGeneric.empty? @memo[:title], @memo[:body]
    session[:error] = MemoGeneric::BLANK_ERROR
    return erb :new
  end

  @memo_manipulator.save @memo[:title], @memo[:body]
  session[:notify] = MemoGeneric::SAVE_COMPLETED
  redirect to('/memos'), 303
end

['/', '/memos'].each do |uri|
  get uri do
    @memos = @memo_manipulator.all
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
  if MemoGeneric.empty? @memo[:title], @memo[:body]
    session[:error] = MemoGeneric::BLANK_ERROR
    return erb :edit
  end

  if @memo_manipulator.update @memo[:id].to_i, @memo[:title], @memo[:body]
    session[:notify] = MemoGeneric::SAVE_COMPLETED
    redirect to('/memos'), 303
  else
    not_found
  end
end

get '/memos/delete/:id' do
  erb :delete
end

delete '/memos/:id' do
  if @memo_manipulator.destroy @memo[:id].to_i
    session[:notify] = MemoGeneric::DELETE_COMPLETED
    redirect to('/memos'), 303
  else
    not_found
  end
end

not_found do
  erb :not_found
end

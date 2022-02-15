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
end

configure do
  enable :sessions
end

before do
  @memo_model = MemoJson.new
end

before '/memos/:action/:id' do
  @memo = @memo_model.find params[:id].to_i
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

  begin
    if @memo_model.save @memo[:title], @memo[:body]
      session[:notify] = MemoGeneric::SAVE_COMPLETED
      redirect to('/memos'), 303
    end
  rescue StandardError
    session[:error] = MemoGeneric::SAVE_FAILURE
    erb :new
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
  if MemoGeneric.empty? @memo[:title], @memo[:body]
    session[:error] = MemoGeneric::BLANK_ERROR
    return erb :edit
  end

  begin
    if @memo_model.update @memo[:id].to_i, @memo[:title], @memo[:body]
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

get '/memos/delete/:id' do
  erb :delete
end

delete '/memos/:id' do
  if @memo_model.destroy @memo[:id].to_i
    session[:notify] = MemoGeneric::DELETE_COMPLETED
    redirect to('/memos'), 303
  else
    not_found
  end
rescue StandardError
  session[:error] = MemoGeneric::DELETE_FAILURE
  @memo = @memo_model.find params[:id].to_i
  erb :delete
end

not_found do
  erb :not_found
end

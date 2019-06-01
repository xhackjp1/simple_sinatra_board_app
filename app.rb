require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

get '/' do
  conn = PG::connect(
    host: ENV['DATABASE_HOST'],
    user: ENV['DATABASE_USER'],
    password: ENV['DATABASE_PASSWORD'],
    dbname: ENV['DATABASE_NAME'],
    port: ENV['DATABASE_PORT']
  )
  @data = conn.exec("select * from board_contents;")
  conn.finish
  erb :index
end

post '/comments' do
  name = params["name"]
  comment = params["comment"]
  conn = PG::connect(
    host: ENV['DATABASE_HOST'],
    user: ENV['DATABASE_USER'],
    password: ENV['DATABASE_PASSWORD'],
    dbname: ENV['DATABASE_NAME'],
    port: ENV['DATABASE_PORT']
  )
  sql = "INSERT INTO board_contents (name, comment) VALUES ('#{name}', '#{comment}');"
  @data = conn.exec(sql)
  redirect '/'
end

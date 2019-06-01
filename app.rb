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
  @data = conn.exec("select * from comments;")
  conn.finish
  erb :index
end

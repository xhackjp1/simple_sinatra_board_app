require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'
require './image_uploader'

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

get '/test' do
  return %Q{
    <form action="upload" method="post" accept-charset="utf-8" enctype="multipart/form-data">
      <div>
        <input type="file" name="file" value="" id="file">
      </div>
      <div>
        <input type="submit" value="Upload &uarr;">
      </div>
    </form>
  }
end

post '/upload' do
  image_uploader = ImageUploader.new(params[:file])
  if image_uploader.upload_image
    %Q{
      <div>
        <p>アップロードに成功しました</p>
        <img src="#{image_uploader.public_url}" alt="ライオンの画像" width="314" height="229" border="0" />
      </div>
    }
  else
    %Q{
      アップロードに失敗しました
    }
  end
end

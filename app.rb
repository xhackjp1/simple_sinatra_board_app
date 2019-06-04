require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

class ImageUploader
  require 'aws-sdk-s3' # aws-sdk-s3 読み込み

  def initialize(upload_image)
    @file = upload_image["tempfile"]  # アップロードするファイル
    @type = upload_image["Content-Type"]
    @key_name = "#{SecureRandom.hex}"  # バケットに置く際のキー名

    @s3 = Aws::S3::Resource.new(
        region: 'ap-northeast-1',  # リージョン東京
        credentials: Aws::Credentials.new(
            ENV['AWS_S3_ACCESS_KEY_ID'], # S3用アクセスキー
            ENV['AWS_S3_SECRET_ACCESS_KEY'] # S3用シークレットアクセスキー
        )
    )
  end

  def upload_image
    begin
      @s3.bucket(get_bucket_name)
          .object(@key_name)
          .put(body: @file, content_type: @type, acl: 'public-read')
      return true
    rescue StandardError => e
      puts "アップロードに失敗しました：#{e}"
      return false
    end
  end

  def public_url
    @s3.bucket(get_bucket_name).object(@key_name).public_url
  end

  private

    def get_bucket_name
      ENV['AWS_S3_BUCKET_NAME']
    end
end

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

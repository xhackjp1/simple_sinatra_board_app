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

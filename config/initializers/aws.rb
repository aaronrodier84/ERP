settings_present = defined?(Setting) && Setting.table_exists?
key_id = settings_present ? Setting.first&.aws_access_key_id : ''
secret_key = settings_present ? Setting.first&.aws_secret_key : ''

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(key_id, secret_key)
})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

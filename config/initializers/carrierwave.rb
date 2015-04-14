# http://stackoverflow.com/questions/7534341/rails-3-test-fixtures-with-carrierwave/25315883#25315883
# NullStorage provider for CarrierWave for use in tests.  Doesn't actually
# upload or store files but allows test to pass as if files were stored and
# the use of fixtures.
class NullStorage
  attr_reader :uploader

  def initialize(uploader)
    @uploader = uploader
  end

  def identifier
    uploader.filename
  end

  def store!(_file)
    true
  end

  def retrieve!(_identifier)
    true
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      provider:              'AWS',                        # required
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],                        # required
    }
    config.fog_directory  = 'parrote'                          # required
    config.fog_public     = false                                        # optional, defaults to true
    config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}
  end
elsif Rails.env.test?
  CarrierWave.configure do |config|
    config.storage NullStorage
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
end
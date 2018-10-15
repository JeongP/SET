CarrierWave.configure do |config|
  config.fog_provider = 'fog/google'                        # required
  config.fog_credentials = {
    provider:                         'Google',
    google_storage_access_key_id:     'GOOG63D5YJWK6HJLYR3DKVHZ',
    google_storage_secret_access_key: 'XxP15L9OtLFHbaVwknka6I54fWbSc4seArpRCdmd'
  }
  config.fog_directory = 'speech-set'
end
# encoding: utf-8

class RecordUploader < CarrierWave::Uploader::Base
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def self.fog_public
    true
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end

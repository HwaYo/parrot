class RequestNrJob
  include SuckerPunch::Job

  def perform(record)
    uri = URI.parse(ENV['NOISE_REDUCTION_API_URL'])
    params = { :url => record.file.url , :uuid => record.uuid }
    uri.query = URI.encode_www_form( params )

    puts Net::HTTP.get(uri)
  end
end

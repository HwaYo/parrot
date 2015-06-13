class RequestNrJob
  include SuckerPunch::Job

  def perform(record)
    if Rails.env.production?
      uri = URI.parse("http://nr.devsusu.info/nr")
    else
      uri = URI.parse("http://localhost:4567/nr")
    end

    params = { :url => record.file.url , :uuid => record.uuid }

    uri.query = URI.encode_www_form( params )
    puts Net::HTTP.get(uri)
  end
end

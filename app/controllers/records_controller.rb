class RecordsController < ApplicationController
  def new
  end

  def create
    directory = "public/upload"
    name = "#{Time.now.strftime('%Y%m%d%H%M%S')}.wav"
    path = File.join(directory, name)

    File.open(path, "wb") { |f| f.write(params[:data].read) }
    render plain: "Saved as #{name}."
  end
end

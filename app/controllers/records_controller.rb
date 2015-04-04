class RecordsController < ApplicationController
  def index
    @records = Record.order(created_at: :desc)
  end

  def new
    @record = current_user.records.new
  end

  def create
    record = current_user.records.new(record_params)
    record.title = "#{Time.now.strftime('%Y%m%d%H%M%S')}"
    record.save!

    render json: {
      href: record_path(record)
    }
  end

  def show
    @record = Record.find(params[:id])
  end

  def bookmark_json
    @record = Record.find(params[:id])
    puts @record.bookmark
    render json: @record.bookmark
  end

private
  def record_params
    params.permit(:file, :note, :bookmark)
  end
end

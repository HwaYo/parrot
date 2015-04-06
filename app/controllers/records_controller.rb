class RecordsController < ApplicationController
  def index
    @records = Record.order(created_at: :desc)
  end

  def new
    @record = current_user.records.new
  end

  def edit
    @record = Record.find(params[:id])
    render partial: "edit_modal"
  end

  def update
    @record = Record.find(params[:id])

    if @record.update(record_params)
      redirect_to records_path
    else
      render partial: "edit_modal", status: 500
    end
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

  def destroy
    @record = Record.find(params[:id])
    @record.destroy!
    redirect_to records_path
  end

private
  def record_params
    params.require(:record).permit(:title, :file, :note, :bookmark)
  end
end

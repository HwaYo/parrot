class RecordsController < ApplicationController
  def index
    @records = current_user.records.remaining.order(created_at: :desc)
  end

  def new
    @record = current_user.records.new
    @bookmarks = current_user.bookmarks
  end

  def edit
    @record = current_user.records.find(params[:id])
    render partial: "edit_modal"
  end

  def update
    @record = current_user.records.find(params[:id])

    if @record.update(record_params)
      redirect_to records_path
    else
      render partial: "edit_modal", status: 500
    end
  end

  def create
    record = current_user.records.new(record_params)
    record.title = "#{Time.now.strftime('%Y년 %m월 %d일 %H시 %M분에 남긴 녹음본')}"

    record.transaction do
      if record.bookmark
        bookmark_histories = JSON.parse(record.bookmark)
        bookmark_histories.each do |history|
          bookmark = Bookmark.find_by_name(history["name"])
          next if bookmark.nil?

          bookmark_history = record.bookmark_histories.build(history.slice(*BookmarkHistory.column_names))
          bookmark_history.bookmark = bookmark
          bookmark_history.save!
        end
      end

      record.save!
    end

    render json: {
      href: record_path(record)
    }
  end

  def show
    @record = current_user.records.find(params[:id])
    @bookmarks = current_user.bookmarks
  end

  def bookmark_json
    @record = current_user.records.find(params[:id])
    render json: @record.bookmark
  end

  def destroy
    @record = Record.find(params[:id])
    @record.deleted = true
    @record.save!
    redirect_to records_path
  end

private
  def record_params
    params.require(:record).permit(:title, :file, :note, :bookmark)
  end
end

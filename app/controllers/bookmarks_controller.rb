class BookmarksController < ApplicationController
  def index
    @bookmarks = current_user.bookmarks.order(created_at: :desc)
  end

  def create
    bookmark = current_user.bookmarks.new(bookmark_params)
    bookmark.save!
    redirect_to bookmarks_path
  end

  def update
    @bookmark = current_user.bookmarks.find(params[:id])

    if @bookmark.update(bookmark_params)
      redirect_to bookmarks_path
    else
      render partial: "edit", status: 500
    end
  end

  def edit
    @bookmark = current_user.bookmarks.find(params[:id])
    render partial: "edit"
  end

  def destroy
    bookmark = current_user.bookmarks.find(params[:id])
    bookmark.destroy

    redirect_to bookmarks_path
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:name, :color)
  end
end


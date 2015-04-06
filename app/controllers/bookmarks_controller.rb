class BookmarksController < ApplicationController
  def index
    @bookmarks = Bookmark.order(created_at: :desc)
  end

  def create
    bookmark = current_user.bookmarks.new(bookmark_params)
    bookmark.save!
    redirect_to bookmarks_path
  end

  def update
    @bookmark = Bookmark.find(params[:id])

    if @bookmark.update(bookmark_params)
      redirect_to bookmarks_path
    else
      render partial: "edit_modal", status: 500
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
    render partial: "edit_modal"
  end

  def destroy
    bookmark = Bookmark.find(params[:id])
    bookmark.destroy

    redirect_to bookmarks_path
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:name, :color)
  end
end


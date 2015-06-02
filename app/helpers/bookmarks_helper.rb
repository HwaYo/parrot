module BookmarksHelper
  def link_to_delete(condition, name, options={}, html_options={}, &block)
    html_options[:data] = nil if condition == 0

    link_to(name, options, html_options, &block)
  end
end

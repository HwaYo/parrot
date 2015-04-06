class BookmarkFormBuilder < ActionView::Helpers::FormBuilder
  def form_group(label, *args, &block)
    form_classes = %w(form-group)
    form_classes << 'validate-has-error' if @object.errors.messages[label].present?
    @template.content_tag(:div, *args, class: form_classes.join(' ')) do
      @template.concat yield if block_given?
      @object.errors.messages[label].each do |message|
        @template.concat @template.content_tag(:span, message, for: label, class: 'validate-has-error')
      end
    end
  end
end
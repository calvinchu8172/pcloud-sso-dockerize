ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  Rails.logger.debug "HTML_TAG:"
  Rails.logger.debug html_tag
  Rails.logger.debug "Instance:"
  instance.error_message.each do |i|
    Rails.logger.debug i
  end
  if html_tag =~ /th_label/
    if html_tag =~ /checkbox/
      %{#{html_tag}<div class="zyxel_arlert_area"><label for="#{instance.send(:tag_id)}" class="error_message">#{instance.error_message.first}</label></div>}.html_safe
    else
      %{#{html_tag}}.html_safe
    end
  elsif html_tag =~ /td_field/
    %{<div class="input_error">#{html_tag}</div><div class="error"><div class="zyxel_arlert_area"><label for="#{instance.send(:tag_id)}" class="error_message">#{instance.error_message.first}</label></div></div>}.html_safe
  else
    %{<div class="field_with_errors">#{html_tag}</div>}.html_safe
  end
end
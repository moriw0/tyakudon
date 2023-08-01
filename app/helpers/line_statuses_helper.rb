module LineStatusesHelper
  def line_type_badge(line_status)
    case line_status.line_type
    when 'seated'
      content_tag(:span, line_status.line_type_i18n, class: 'type-badge badge-green')
    when 'inside_the_store'
      content_tag(:span, line_status.line_type_i18n, class: 'type-badge badge-yellow')
    when 'outside_the_store'
      content_tag(:span, line_status.line_type_i18n, class: 'type-badge badge-red')
    end
  end
end

module LineStatusesHelper
  def line_type_badge(line_status)
    case line_status.line_type
    when 'seated'
      content_tag(:span, line_status_content(line_status), class: 'type-badge badge-green')
    when 'inside_the_store'
      content_tag(:span, line_status_content(line_status), class: 'type-badge badge-yellow')
    when 'outside_the_store'
      content_tag(:span, line_status_content(line_status), class: 'type-badge badge-red')
    end
  end

  def line_status_content(line_status)
    if line_status.line_type == 'seated'
      "#{line_status.line_type_i18n}"
    else
      "#{line_status.line_type_i18n} - #{line_status.line_number}人"
    end
  end
end

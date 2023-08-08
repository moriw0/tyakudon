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

  def status_badge_class(line_type)
    case line_type
    when 'inside_the_store'
      'type-badge badge-yellow'
    when 'outside_the_store'
      'type-badge badge-red'
    when 'seated'
      'type-badge badge-green'
    else
      'bg-secondary'
    end
  end
end

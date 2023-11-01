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
    if line_status.line_type == 'seated' || line_status.line_number.nil?
      line_status.line_type_i18n.to_s
    else
      "#{line_status.line_type_i18n} - #{line_status.line_number}人"
    end
  end

  def passed_time_from_first_line_status(line_status)
    first_line_status = line_status.record.line_statuses.first
    distance_of_time_in_words(first_line_status.created_at, line_status.created_at, compact: true)
  end
end

module BreadcrumbsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def add_breadcrumb(name, path = nil)
    @breadcrumbs ||= []
    @breadcrumbs << { name: name, path: path }
  end

  def render_breadcrumbs
    return if @breadcrumbs.blank?

    # safe_join escapes non-html_safe strings (e.g. user-supplied names),
    # so XSS from @ramen_shop.name, @user.name, etc. is prevented automatically.
    tag.nav('aria-label': 'Breadcrumb') do
      tag.ol(class: 'breadcrumb') { safe_join(breadcrumb_items) }
    end
  end

  private

  def breadcrumb_items
    @breadcrumbs.map.with_index do |crumb, index|
      last = index == @breadcrumbs.length - 1
      content = last ? crumb[:name] : crumb_content(crumb)
      # aria-current="page" marks the current page for screen readers
      options = last ? { 'aria-current': 'page' } : {}
      tag.li(content, **options)
    end
  end

  def crumb_content(crumb)
    crumb[:path] ? link_to(crumb[:name], crumb[:path]) : crumb[:name]
  end
  # rubocop:enable Rails/HelperInstanceVariable
end

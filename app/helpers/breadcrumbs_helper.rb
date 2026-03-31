module BreadcrumbsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def add_breadcrumb(name, path = nil)
    @breadcrumbs ||= []
    @breadcrumbs << { name: name, path: path }
  end

  def render_breadcrumbs
    return if @breadcrumbs.blank?

    items = @breadcrumbs.map.with_index do |crumb, index|
      last = index == @breadcrumbs.length - 1
      content = if crumb[:path] && !last
                  link_to(crumb[:name], crumb[:path])
                else
                  crumb[:name]
                end
      # aria-current="page" marks the current page for screen readers
      options = last ? { 'aria-current': 'page' } : {}
      tag.li(content, **options)
    end

    tag.nav('aria-label': 'Breadcrumb') do
      # safe_join escapes non-html_safe strings (e.g. user-supplied names),
      # so XSS from @ramen_shop.name, @user.name, etc. is prevented automatically.
      tag.ol(class: 'breadcrumb') { safe_join(items) }
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable
end

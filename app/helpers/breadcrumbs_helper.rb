module BreadcrumbsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def add_breadcrumb(name, path = nil)
    @breadcrumbs ||= []
    @breadcrumbs << { name: name, path: path }
  end

  def render_breadcrumbs
    return unless defined?(@breadcrumbs) && @breadcrumbs.present?

    crumbs = @breadcrumbs.map.with_index do |crumb, index|
      last = index == @breadcrumbs.length - 1
      if crumb[:path] && !last
        link_to(crumb[:name], crumb[:path])
      else
        crumb[:name]
      end
    end

    tag.p safe_join(crumbs, ' &gt; '.html_safe)
  end
  # rubocop:enable Rails/HelperInstanceVariable
end

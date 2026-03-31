require 'rails_helper'

RSpec.describe BreadcrumbsHelper do
  describe '#render_breadcrumbs' do
    context 'when no breadcrumbs are added' do
      it 'returns nil' do
        expect(helper.render_breadcrumbs).to be_nil
      end
    end

    context 'when a single breadcrumb is added' do
      before { helper.add_breadcrumb '着丼', '/' }

      it 'renders a nav with aria-label' do
        expect(helper.render_breadcrumbs).to have_selector('nav[aria-label="Breadcrumb"]')
      end

      it 'renders the label as plain text inside li (no link, since it is the last item)' do
        expect(helper.render_breadcrumbs).to_not have_selector('a')
        expect(helper.render_breadcrumbs).to include('着丼')
      end

      it 'marks the last item with aria-current="page"' do
        expect(helper.render_breadcrumbs).to have_selector('li[aria-current="page"]', text: '着丼')
      end
    end

    context 'when multiple breadcrumbs are added' do
      before do
        helper.add_breadcrumb '着丼', '/'
        helper.add_breadcrumb '店舗一覧', '/ramen_shops'
        helper.add_breadcrumb '麺屋さくら'
      end

      it 'renders intermediate items as links inside li' do
        result = helper.render_breadcrumbs
        expect(result).to have_selector('li a[href="/"]', text: '着丼')
        expect(result).to have_selector('li a[href="/ramen_shops"]', text: '店舗一覧')
      end

      it 'renders the last item as plain text without a link' do
        result = helper.render_breadcrumbs
        expect(result).to_not have_selector('a', text: '麺屋さくら')
        expect(result).to include('麺屋さくら')
      end

      it 'marks the last item with aria-current="page"' do
        expect(helper.render_breadcrumbs).to have_selector('li[aria-current="page"]', text: '麺屋さくら')
      end

      it 'does not mark intermediate items with aria-current' do
        result = helper.render_breadcrumbs
        expect(result).to_not have_selector('li[aria-current] a[href="/"]')
      end
    end

    context 'when breadcrumb name contains XSS payload (last item, plain text)' do
      before { helper.add_breadcrumb '<script>alert(1)</script>' }

      it 'escapes the name to prevent XSS' do
        result = helper.render_breadcrumbs
        expect(result).to_not include('<script>')
        expect(result).to include('&lt;script&gt;')
      end
    end

    context 'when breadcrumb name contains XSS payload (linked intermediate item)' do
      before do
        helper.add_breadcrumb '<script>alert(1)</script>', '/evil'
        helper.add_breadcrumb '現在地'
      end

      it 'escapes the link text to prevent XSS' do
        result = helper.render_breadcrumbs
        expect(result).to_not include('<script>')
        expect(result).to include('&lt;script&gt;')
      end
    end
  end

  describe '#add_breadcrumb' do
    it 'appends breadcrumbs in order' do
      helper.add_breadcrumb '着丼', '/'
      helper.add_breadcrumb '店舗一覧', '/ramen_shops'
      result = helper.render_breadcrumbs
      expect(result).to have_link('着丼', href: '/')
      expect(result).to include('店舗一覧')
    end

    it 'accepts a breadcrumb without a path' do
      helper.add_breadcrumb '現在地'
      result = helper.render_breadcrumbs
      expect(result).to_not have_selector('a')
      expect(result).to include('現在地')
    end
  end
end

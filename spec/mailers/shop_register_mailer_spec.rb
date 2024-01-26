require 'rails_helper'

RSpec.describe ShopRegisterMailer do
  describe 'shop_register_request' do
    let!(:user) { create(:user, email: 'user@example.com') }
    let!(:shop_request) { create(:shop_register_request, status: 'open', user: user) }
    let(:mail) { described_class.shop_register_request(shop_request) }

    it 'renders the headers' do
      expect(mail.subject).to eq '店舗登録リクエスト'
      expect(mail.to).to eq [ENV.fetch('ADMIN_EMAIL')]
      expect(mail.from).to eq ['noreply@mail.tyakudon.com']
    end

    it 'renders the body' do
      expect(mail.body).to match shop_request.user.name
      expect(mail.body).to match shop_request.name
      expected_url = "http://example.com/shop_register_requests/#{shop_request.id}/edit"
      expect(mail.body).to include(expected_url)
    end
  end

  describe 'registration_complete_email' do
    let!(:user) { create(:user, email: 'user@example.com') }
    let!(:ramen_shop) { create(:ramen_shop) }
    let(:mail) { described_class.registration_complete_email(user: user, ramen_shop: ramen_shop) }

    it 'renders the headers' do
      expect(mail.subject).to eq('店舗登録が完了しました | ちゃくどん')
      expect(mail.to).to eq(['user@example.com'])
      expect(mail.from).to eq(['noreply@mail.tyakudon.com'])
    end

    it 'renders the body' do
      expect(mail.html_part.body).to match user.name
      expect(mail.html_part.body).to match ramen_shop.name
      expected_url = "http://example.com/ramen_shops/#{ramen_shop.id}"
      expect(mail.html_part.body).to include(expected_url)
    end
  end
end

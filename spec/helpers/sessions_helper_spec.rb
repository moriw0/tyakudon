require 'rails_helper'

RSpec.describe SessionsHelper do
  let(:user) { create(:user) }

  describe 'current_user' do
    before do
      remember(user)
    end

    it 'returns right when session is nil' do
      expect(current_user).to eq user
      expect(is_logged_in?).to be_truthy
    end

    # rubocop:disable Rails/SkipsModelValidations
    it 'returns nil when remember digest is wrong' do
      user.update_attribute(:remember_digest, User.digest(User.new_token))
      expect(current_user).to be_nil
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end

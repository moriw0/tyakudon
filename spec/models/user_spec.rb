require 'rails_helper'

RSpec.describe User do
  let(:user) { build(:user) }
  let(:ramen_shop) { create(:ramen_shop) }

  it 'is valid with name and email' do
    new_user = described_class.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar',
      avatar: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_8.4MB.png').to_s)
    )

    expect(new_user).to be_valid
  end

  it 'is invalid without a name' do
    user.name =  '    '
    user.valid?
    expect(user.errors[:name]).to include('ニックネームを入力してください。')
  end

  it 'is invalid without an email' do
    user.email = '    '
    user.valid?
    expect(user.errors[:email]).to include('メールアドレスを入力してください。')
  end

  it 'is invalid without a too long name' do
    user.name = 'a' * 51
    user.valid?
    expect(user.errors[:name]).to include('ニックネームは50文字以内で入力してください。')
  end

  it 'is invalid without a too long email' do
    user.email = "#{'a' * 244}@example.com"
    user.valid?
    expect(user.errors[:email]).to include('メールアドレスは255文字以内で入力してください。')
  end

  it 'is invalid with a 9.5 MB image' do
    user.avatar = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_9.5MB.png').to_s)
    user.valid?
    expect(user.errors[:avatar]).to include 'アバターのファイルサイズは9MB以下にしてください。'
  end

  it 'is invalid with a gif image' do
    user.avatar = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ramen.gif').to_s)
    user.valid?
    expect(user.errors[:avatar]).to include 'アップロードできないファイル形式です。'
  end

  it 'is valid with valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM
                         A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user.email = valid_address
      expect(user).to be_valid
    end
  end

  it 'is invalid with invalid addresses' do
    invalid_addresses = %w[user@example,com
                           user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com
                           foo@bar..com]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).to be_invalid, "#{invalid_address.inspect}が無効ではありません"
    end
  end

  it 'is invalid with duplicate address' do
    new_user = create(:user)
    duplicate_user = new_user.dup
    duplicate_user.valid?
    expect(duplicate_user.errors[:email]).to include('メールアドレスがすでに使用されています。')
  end

  it 'saves email addresses as lowercase' do
    user.email = 'Foo@ExAMPle.CoM'
    user.save
    expect(user.reload.email).to eq 'foo@example.com'
  end

  describe 'password validations' do
    it 'returns an error when the password is blank' do
      user.password = user.password_confirmation = ' ' * 6
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('パスワードを入力してください。')
    end

    it 'returns an error when the password is less than 6 characters' do
      user.password = user.password_confirmation = 'a' * 5
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('パスワードは6文字以上で入力してください。')
    end

    it 'returns an error when the password is too long' do
      user.password = user.password_confirmation = 'a' * 73
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('パスワードは72文字以内で入力してください。')
    end

    it 'returns an error when password and password confirmation do not match' do
      user.password = 'password'
      user.password_confirmation = 'different'
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include('パスワードが一致しません。')
    end

    it 'skips password validation when uid exists' do
      user.uid = '123456'
      user.password = user.password_confirmation = nil
      expect(user).to be_valid
    end
  end

  specify 'authenticated? should return false for a user with nil digest' do
    expect(user).to_not be_authenticated(:remember, '')
  end

  it 'raises exception when delete user with its record' do
    user = create(:user)
    create(:record, user: user)
    expect { user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
  end

  it 'adds favorite and removes favorite' do
    expect(user).to_not be_favorites(ramen_shop)
    user.add_favorite(ramen_shop)
    expect(user).to be_favorites(ramen_shop)
    user.remove_favorite(ramen_shop)
    expect(user).to_not be_favorites(ramen_shop)
  end

  describe '.digest' do
    it 'returns a BCrypt hash string' do
      digest = described_class.digest('test_string')
      expect(BCrypt::Password.new(digest).is_password?('test_string')).to be true
    end
  end

  describe '.new_token' do
    it 'returns a URL-safe base64 token' do
      token = described_class.new_token
      expect(token).to match(/\A[A-Za-z0-9\-_]+\z/)
    end

    it 'returns a unique token each time' do
      expect(described_class.new_token).to_not eq(described_class.new_token)
    end
  end

  describe '#authenticated?' do
    let(:saved_user) { create(:user) }

    it 'returns true with correct activation token' do
      token = saved_user.activation_token
      expect(saved_user.authenticated?(:activation, token)).to be true
    end

    it 'returns false with wrong activation token' do
      expect(saved_user.authenticated?(:activation, 'wrong_token')).to be false
    end

    it 'returns false when digest is nil' do
      saved_user.remember_digest = nil
      expect(saved_user.authenticated?(:remember, '')).to be false
    end
  end

  describe '#remember and #forget' do
    let(:saved_user) { create(:user) }

    it 'sets remember_digest when remembered' do
      saved_user.remember
      expect(saved_user.reload.remember_digest).to_not be_nil
    end

    it 'clears remember_digest when forgotten' do
      saved_user.remember
      saved_user.forget
      expect(saved_user.reload.remember_digest).to be_nil
    end
  end

  describe '#session_token' do
    let(:saved_user) { create(:user) }

    context 'when remember_digest exists' do
      it 'returns the existing remember_digest' do
        saved_user.remember
        digest = saved_user.reload.remember_digest
        expect(saved_user.session_token).to eq digest
      end
    end

    context 'when remember_digest is nil' do
      it 'calls remember and returns a new digest' do
        expect(saved_user.remember_digest).to be_nil
        token = saved_user.session_token
        expect(token).to_not be_nil
        expect(saved_user.reload.remember_digest).to_not be_nil
      end
    end
  end

  describe '#activate' do
    let(:inactive_user) { create(:user, :not_activated) }

    it 'sets activated to true' do
      inactive_user.activate
      expect(inactive_user.reload.activated).to be true
    end

    it 'sets activated_at' do
      inactive_user.activate
      expect(inactive_user.reload.activated_at).to_not be_nil
    end
  end

  describe '#create_reset_digest' do
    let(:saved_user) { create(:user) }

    it 'sets reset_digest' do
      saved_user.create_reset_digest
      expect(saved_user.reload.reset_digest).to_not be_nil
    end

    it 'sets reset_sent_at' do
      saved_user.create_reset_digest
      expect(saved_user.reload.reset_sent_at).to_not be_nil
    end
  end

  describe '#password_reset_expired?' do
    let(:saved_user) { create(:user) }

    it 'returns true when reset_sent_at is more than 2 hours ago' do
      saved_user.create_reset_digest
      saved_user.update_column(:reset_sent_at, 3.hours.ago) # rubocop:disable Rails/SkipsModelValidations
      expect(saved_user.password_reset_expired?).to be true
    end

    it 'returns false when reset_sent_at is within 2 hours' do
      saved_user.create_reset_digest
      expect(saved_user.password_reset_expired?).to be false
    end
  end

  describe '#forget_reset_digest' do
    let(:saved_user) { create(:user) }

    it 'sets reset_digest to nil' do
      saved_user.create_reset_digest
      saved_user.forget_reset_digest
      expect(saved_user.reload.reset_digest).to be_nil
    end
  end

  describe '#unread_announcements?' do
    let(:saved_user) { create(:user) }

    context 'when last_read_announcement_at is nil' do
      it 'returns true when published announcements exist' do
        create(:announcement)
        expect(saved_user.unread_announcements?).to be true
      end
    end

    context 'when last_read_announcement_at is older than the latest published_at' do
      it 'returns true' do
        create(:announcement, published_at: 1.hour.ago)
        saved_user.update_column(:last_read_announcement_at, 2.hours.ago) # rubocop:disable Rails/SkipsModelValidations
        expect(saved_user.unread_announcements?).to be true
      end
    end

    context 'when last_read_announcement_at is equal to or newer than the latest published_at' do
      it 'returns false' do
        create(:announcement, published_at: 2.hours.ago)
        saved_user.update_column(:last_read_announcement_at, 1.hour.ago) # rubocop:disable Rails/SkipsModelValidations
        expect(saved_user.unread_announcements?).to be false
      end
    end

    context 'when no published announcements exist' do
      it 'returns false' do
        create(:announcement, :draft)
        expect(saved_user.unread_announcements?).to be false
      end

      it 'returns false when there are no announcements at all' do
        expect(saved_user.unread_announcements?).to be false
      end
    end
  end

  describe '#build_with_omniauth' do
    let(:auth) do
      {
        'provider' => 'google_oauth2',
        'uid' => '987654',
        'info' => { 'email' => 'oauth@example.com' }
      }
    end

    it 'assigns provider from auth data' do
      user.build_with_omniauth(auth)
      expect(user.provider).to eq 'google_oauth2'
    end

    it 'assigns uid from auth data' do
      user.build_with_omniauth(auth)
      expect(user.uid).to eq '987654'
    end

    it 'assigns email from auth data' do
      user.build_with_omniauth(auth)
      expect(user.email).to eq 'oauth@example.com'
    end
  end
end

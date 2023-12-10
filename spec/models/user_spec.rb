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
      avatar: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png').to_s)
    )

    expect(new_user).to be_valid
  end

  it 'is invalid without a name' do
    user.name =  '    '
    user.valid?
    expect(user.errors[:name]).to include('を入力してください')
  end

  it 'is invalid without an email' do
    user.email = '    '
    user.valid?
    expect(user.errors[:email]).to include('を入力してください')
  end

  it 'is invalid without a too long name' do
    user.name = 'a' * 51
    user.valid?
    expect(user.errors[:name]).to include('は50文字以内で入力してください')
  end

  it 'is invalid without a too long email' do
    user.email = "#{'a' * 244}@example.com"
    user.valid?
    expect(user.errors[:email]).to include('は255文字以内で入力してください')
  end

  it 'is invalid with a 5.2 MB image' do
    user.avatar = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_5.3MB.png').to_s)
    user.valid?
    expect(user.errors[:avatar]).to include 'は5MB以下である必要があります'
  end

  it 'is invalid with a gif image' do
    user.avatar = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ramen.gif').to_s)
    user.valid?
    expect(user.errors[:avatar]).to include 'のフォーマットが不正です'
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
    expect(duplicate_user.errors[:email]).to include('はすでに存在します')
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
      expect(user.errors[:password]).to include('を入力してください')
    end

    it 'returns an error when the password is less than 6 characters' do
      user.password = user.password_confirmation = 'a' * 5
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('は6文字以上で入力してください')
    end

    it 'returns an error when the password is too long' do
      max_length = ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
      user.password = user.password_confirmation = 'a' * (max_length + 1)
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("は#{max_length}文字以内で入力してください")
    end

    it 'returns an error when password and password confirmation do not match' do
      user.password = 'password'
      user.password_confirmation = 'different'
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include('とパスワードの入力が一致しません')
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
end

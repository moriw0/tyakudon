require 'rails_helper'

RSpec.describe User do
  let(:user) { build(:user) }

  it 'is valid with name and email' do
    new_user = described_class.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar'
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

  it 'is invalid with blank password' do
    user.password = user.password_confirmation = ' ' * 6
    user.valid?
    expect(user.errors[:password]).to include('を入力してください')
  end

  specify 'password should have a minimum length' do
    user.password = user.password_confirmation = 'a' * 5
    user.valid?
    expect(user.errors[:password]).to include('は6文字以上で入力してください')
  end

  specify 'authenticated? should return false for a user with nil digest' do
    expect(user.authenticated?('')).to_not be_truthy
  end
end

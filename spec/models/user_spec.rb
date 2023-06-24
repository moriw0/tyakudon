require 'rails_helper'

RSpec.describe User do
  it 'is valid with name and email' do
    user = described_class.new(
      name: 'Example User',
      email: 'user@example.com'
    )

    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    new_user = build(:user, name: '    ')
    new_user.valid?
    expect(new_user.errors[:name]).to include('を入力してください')
  end

  it 'is invalid without an email' do
    new_user = build(:user, email: '    ')
    new_user.valid?
    expect(new_user.errors[:email]).to include('を入力してください')
  end

  it 'is invalid without a too long name' do
    new_user = build(:user, name: 'a' * 51)
    new_user.valid?
    expect(new_user.errors[:name]).to include('は50文字以内で入力してください')
  end

  it 'is invalid without a too long email' do
    new_user = build(:user, email: "#{'a' * 244}@example.com")
    new_user.valid?
    expect(new_user.errors[:email]).to include('は255文字以内で入力してください')
  end

  it 'is valid with valid addresses' do
    new_user = build(:user)
    valid_addresses = %w[user@example.com USER@foo.COM
                         A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      new_user.email = valid_address
      expect(new_user).to be_valid
    end
  end

  it 'is invalid with invalid addresses' do
    new_user = build(:user)
    invalid_addresses = %w[user@example,com
                           user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com
                           foo@bar..com]
    invalid_addresses.each do |invalid_address|
      new_user.email = invalid_address
      expect(new_user).to be_invalid, "#{invalid_address.inspect}が無効ではありません"
    end
  end

  it 'is invalid with duplicate address' do
    new_user = create(:user)
    duplicate_user = new_user.dup
    duplicate_user.valid?
    expect(duplicate_user.errors[:email]).to include('はすでに存在します')
  end

  it "saves email addresses as lowercase" do
    user = build(:user, email: "Foo@ExAMPle.CoM")
    user.save
    expect(user.reload.email).to eq "foo@example.com"
  end
end

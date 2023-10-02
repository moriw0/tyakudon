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

  describe 'feed' do
    let(:ramen_shops) { create_list(:many_shops, 3) }
    let(:user) { create(:user) }

    before do
      ramen_shops.each do |ramen_shop|
        create_list(:many_records, 3, ramen_shop: ramen_shop, user: user, skip_validation: true)
      end

      create(:favorite, user: user, ramen_shop: ramen_shops.first)
      create(:favorite, user: user, ramen_shop: ramen_shops.second)
    end

    describe '#favorite_records' do
      it 'retrieves all records from favorited ramen_shops' do
        expect(user.feed.count).to eq(6)  # 2 ramen shops * 3 records each = 6 records

        user.feed.each do |record|
          # Ensure the records belong to the ramen_shops favorited by the user
          expect(user.favorite_shops).to include(record.ramen_shop)
        end
      end
    end
  end
end

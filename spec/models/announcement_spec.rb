require 'rails_helper'

RSpec.describe Announcement do
  describe 'validations' do
    it 'is valid with title and published_at' do
      announcement = build(:announcement)
      expect(announcement).to be_valid
    end

    it 'is invalid without a title' do
      announcement = build(:announcement, title: nil)
      announcement.valid?
      expect(announcement.errors[:title]).to be_present
    end

    it 'is invalid with a blank title' do
      announcement = build(:announcement, title: '   ')
      announcement.valid?
      expect(announcement.errors[:title]).to be_present
    end

    it 'is invalid without published_at' do
      announcement = build(:announcement, published_at: nil)
      announcement.valid?
      expect(announcement.errors[:published_at]).to be_present
    end
  end

  describe '.published' do
    it 'returns announcements with published_at in the past' do
      published = create(:announcement, published_at: 1.hour.ago)
      expect(described_class.published).to include(published)
    end

    it 'does not return announcements with published_at in the future' do
      draft = create(:announcement, :draft)
      expect(described_class.published).to_not include(draft)
    end
  end

  describe '.recent' do
    it 'returns announcements ordered by published_at descending' do
      older = create(:announcement, published_at: 2.days.ago)
      newer = create(:announcement, published_at: 1.day.ago)
      expect(described_class.recent.to_a).to eq([newer, older])
    end
  end
end

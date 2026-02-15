require 'rails_helper'

RSpec.describe CheerMessage do
  describe 'Associations' do
    it 'is invalid without a record' do
      cheer_message = build(:cheer_message, record: nil)
      expect(cheer_message).to_not be_valid
      expect(cheer_message.errors[:record]).to be_present
    end

    it 'is valid with a record' do
      cheer_message = build(:cheer_message)
      expect(cheer_message).to be_valid
    end
  end

  describe 'Enum' do
    it 'defines assistant as 10' do
      expect(described_class.roles[:assistant]).to eq 10
    end

    it 'defines user as 20' do
      expect(described_class.roles[:user]).to eq 20
    end

    it 'can set role to assistant' do
      cheer_message = build(:cheer_message, role: :assistant)
      expect(cheer_message.assistant?).to be true
    end

    it 'can set role to user' do
      cheer_message = build(:cheer_message, role: :user)
      expect(cheer_message.user?).to be true
    end
  end

  describe 'Scopes' do
    describe '.recent' do
      let!(:record) { create(:record) }
      let!(:older_message) do
        create(:cheer_message, record: record, created_at: 1.hour.ago)
      end
      let!(:newer_message) do
        create(:cheer_message, record: record, created_at: Time.zone.now)
      end

      it 'returns only the most recent message' do
        result = described_class.recent
        expect(result).to include(newer_message)
        expect(result).to_not include(older_message)
      end
    end
  end

  describe '.for_openai' do
    subject(:result) { described_class.for_openai(messages) }

    let(:record) { create(:record) }
    let(:user_message) { create(:cheer_message, record: record, role: :user, content: 'ユーザーメッセージ') }
    let(:assistant_message) { create(:cheer_message, record: record, role: :assistant, content: 'アシスタントメッセージ') }
    let(:messages) { [user_message, assistant_message] }

    it 'includes the system message at the beginning' do
      expect(result.first[:role]).to eq 'system'
    end

    it 'includes SYSTEM_MESSAGE as the first element' do
      expect(result.first).to eq CheerMessage::SYSTEM_MESSAGE
    end

    it 'maps user role to "user" string' do
      user_entry = result.find { |m| m[:content] == 'ユーザーメッセージ' }
      expect(user_entry[:role]).to eq 'user'
    end

    it 'maps assistant role to "assistant" string' do
      assistant_entry = result.find { |m| m[:content] == 'アシスタントメッセージ' }
      expect(assistant_entry[:role]).to eq 'assistant'
    end

    it 'returns total messages count including system message' do
      expect(result.length).to eq messages.length + 1
    end
  end

  describe '.build_send_message' do
    let(:line_status_with_all) do
      instance_double(LineStatus, line_type: 'outside_the_store', line_number: 10, comment: '長い行列')
    end
    let(:line_status_without_number) do
      instance_double(LineStatus, line_type: 'inside_the_store', line_number: nil, comment: 'コメントあり')
    end
    let(:line_status_without_comment) do
      instance_double(LineStatus, line_type: 'inside_the_store', line_number: 5, comment: nil)
    end
    let(:line_status_minimal) do
      instance_double(LineStatus, line_type: 'seated', line_number: nil, comment: nil)
    end

    it 'includes elapsed time in minutes' do
      result = described_class.build_send_message(1800, line_status_minimal)
      expect(result).to include('経過時間（分）: 30')
    end

    it 'includes line_type' do
      result = described_class.build_send_message(600, line_status_minimal)
      expect(result).to include('行列の状況: seated')
    end

    it 'includes line_number when present' do
      result = described_class.build_send_message(600, line_status_with_all)
      expect(result).to include('行列数: 10')
    end

    it 'excludes line_number when absent' do
      result = described_class.build_send_message(600, line_status_without_number)
      expect(result).to_not include('行列数:')
    end

    it 'includes comment when present' do
      result = described_class.build_send_message(600, line_status_with_all)
      expect(result).to include('ひとこと: 長い行列')
    end

    it 'excludes comment when absent' do
      result = described_class.build_send_message(600, line_status_without_comment)
      expect(result).to_not include('ひとこと:')
    end

    it 'floors partial minutes' do
      result = described_class.build_send_message(90, line_status_minimal)
      expect(result).to include('経過時間（分）: 1')
    end
  end
end

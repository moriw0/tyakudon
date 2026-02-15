require 'rails_helper'

RSpec.describe LineStatusesHelper do
  let(:record) { create(:record) }

  describe '#line_type_badge' do
    context 'when line_type is seated' do
      let(:line_status) { create(:line_status, line_type: 'seated', line_number: nil, record: record) }

      it 'returns a span with badge-green class' do
        result = helper.line_type_badge(line_status)
        expect(result).to include('badge-green')
        expect(result).to include('type-badge')
      end
    end

    context 'when line_type is inside_the_store' do
      let(:line_status) { create(:line_status, line_type: 'inside_the_store', record: record) }

      it 'returns a span with badge-yellow class' do
        result = helper.line_type_badge(line_status)
        expect(result).to include('badge-yellow')
        expect(result).to include('type-badge')
      end
    end

    context 'when line_type is outside_the_store' do
      let(:line_status) { create(:line_status, line_type: 'outside_the_store', record: record) }

      it 'returns a span with badge-red class' do
        result = helper.line_type_badge(line_status)
        expect(result).to include('badge-red')
        expect(result).to include('type-badge')
      end
    end
  end

  describe '#line_status_content' do
    context 'when line_type is seated' do
      let(:line_status) { create(:line_status, line_type: 'seated', line_number: nil, record: record) }

      it 'returns only the line_type_i18n label' do
        result = helper.line_status_content(line_status)
        expect(result).to eq('着席')
      end
    end

    context 'when line_number is nil' do
      let(:line_status) { create(:line_status, line_type: 'inside_the_store', line_number: nil, record: record) }

      it 'returns only the line_type_i18n label' do
        result = helper.line_status_content(line_status)
        expect(result).to eq('店内')
      end
    end

    context 'when line_type is not seated and line_number is present' do
      let(:line_status) { create(:line_status, line_type: 'outside_the_store', line_number: 5, record: record) }

      it 'returns line_type_i18n with line_number' do
        result = helper.line_status_content(line_status)
        expect(result).to eq('店外 - 5人')
      end
    end
  end

  describe '#passed_time_from_first_line_status' do
    let(:first_line_status) { create(:line_status, record: record, created_at: 30.minutes.ago) }
    let(:second_line_status) { create(:line_status, record: record, created_at: Time.zone.now) }

    before do
      first_line_status
      second_line_status
    end

    it 'returns distance of time from the first line_status' do
      result = helper.passed_time_from_first_line_status(second_line_status)
      expect(result).to be_present
    end
  end
end

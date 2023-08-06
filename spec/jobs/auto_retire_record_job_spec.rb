require 'rails_helper'

RSpec.describe AutoRetireRecordJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
  end

  it 'queues the job after create record' do
    expect {
      create(:record)
    }.to change(enqueued_jobs, :size).by(1)
  end

  context 'executes perform' do
    let!(:record) { create(:record) }

    it 'makes record be auto_retired' do
      perform_enqueued_jobs do
        described_class.perform_later(record)
      end

      expect(record.reload.auto_retired).to be_truthy
    end

    it 'sends an email' do
      perform_enqueued_jobs do
        described_class.perform_later(record)
      end

      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
end

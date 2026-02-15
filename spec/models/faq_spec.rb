require 'rails_helper'

RSpec.describe Faq do
  describe 'Validations' do
    it 'is valid with question and answer' do
      faq = described_class.new(question: 'よくある質問？', answer: '回答です。')
      expect(faq).to be_valid
    end

    it 'is invalid without a question' do
      faq = described_class.new(question: nil, answer: '回答です。')
      faq.valid?
      expect(faq.errors[:question]).to be_present
    end

    it 'is invalid with a blank question' do
      faq = described_class.new(question: '   ', answer: '回答です。')
      faq.valid?
      expect(faq.errors[:question]).to be_present
    end

    it 'is invalid without an answer' do
      faq = described_class.new(question: 'よくある質問？', answer: nil)
      faq.valid?
      expect(faq.errors[:answer]).to be_present
    end

    it 'is invalid with a blank answer' do
      faq = described_class.new(question: 'よくある質問？', answer: '   ')
      faq.valid?
      expect(faq.errors[:answer]).to be_present
    end
  end
end

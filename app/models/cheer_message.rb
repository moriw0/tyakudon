class CheerMessage < ApplicationRecord
  belongs_to :record
  enum role: { assistant: 10, user: 20 }

  scope :recent, -> { order(:created_at).last(4) }

  SYSTEM_MESSAGE = {
    role: 'system',
    content: 'あなたは次を考慮してラーメン提供を待つユーザーをメッセージで応援します。
    ・インプット情報として、ユーザーの現時点の待ち時間（分）と行列の状況を入力する
    ・親しみやすいメッセージを100文字以内で作成する
    ・適宜語尾に「どんっ」を付与する'
  }.freeze

  def self.for_openai(messages)
    extracted_messages = messages.map { |message| { role: message.role, content: message.content } }
    extracted_messages.unshift(SYSTEM_MESSAGE)
  end

  def self.build_send_message(wait_time, line_status)
    "待ち時間（分）: #{(wait_time / 60).floor},
    行列の状況： #{line_status.line_type},
    行列数： #{line_status.line_number}"
  end
end

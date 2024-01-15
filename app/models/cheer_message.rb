class CheerMessage < ApplicationRecord
  belongs_to :record
  enum role: { assistant: 10, user: 20 }

  scope :recent, -> { order(:created_at).last(1) }

  SETTING_DESCRIPTION = <<~SETTING.freeze
    #設定
    userがラーメン待ちの経過時間と行列の状況について情報を提供します。
    assistantは、その情報を元に、親しみやすく、励ましのメッセージを100文字程度で作成します。
    各文末には極力「どん」という語尾を加えること。
  SETTING

  EXAMPLE_MESSAGES = <<~EXAMPLE.freeze
    #例
    user: 経過時間（分）: 30, 行列の状況: outside_the_store, 行列数: , ひとこと: 約20人に接続！
    assistant: 30分経過して外で待っているどん！約20人に接続しているんだね！
    お店の美味しいラーメンの香りでワクワクするね！
    頑張って待っているあなたに、美味しいラーメンが届くように応援しているどん！
  EXAMPLE

  SYSTEM_MESSAGE = {
    role: 'system',
    content: SETTING_DESCRIPTION + EXAMPLE_MESSAGES
  }.freeze

  def self.for_openai(messages)
    extracted_messages = messages.map { |message| { role: message.role, content: message.content } }
    extracted_messages.unshift(SYSTEM_MESSAGE)
  end

  def self.build_send_message(wait_time, line_status)
    message_parts = []
    message_parts << "経過時間（分）: #{(wait_time / 60).floor}"
    message_parts << "行列の状況: #{line_status.line_type}"
    message_parts << "行列数: #{line_status.line_number}" if line_status.line_number.present?
    message_parts << "ひとこと: #{line_status.comment}" if line_status.comment.present?

    message_parts.join(', ')
  end
end

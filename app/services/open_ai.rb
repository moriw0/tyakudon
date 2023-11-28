class OpenAi
  class << self
    def generate_cheer_message(wait_time, line_status)
      prompt_messages = build_messages(wait_time / 60, line_status)
      response = call_openai(prompt_messages)
      response.dig('choices', 0, 'message', 'content')
    end

    CHEER_MESSAGE_TEMPLATE = {
      role: 'system',
      content: 'あなたは次を考慮してラーメン提供を待つユーザーをメッセージで応援します。
      ・インプット情報として、ユーザーの現時点の待ち時間（分）と行列の状況を入力する。
      ・親しみやすいメッセージを140文字以内で作成する
      ・適宜語尾に「どんっ」を付与する'
    }.freeze
    def build_messages(wait_time, line_status)
      messages = [CHEER_MESSAGE_TEMPLATE]
      messages << {
        role: 'user',
        content: "待ち時間（分）: #{wait_time},
          行列の状況： #{line_status.line_type},
          行列数： #{line_status.line_number}"
      }
      messages
    end

    def call_openai(messages)
      OpenAI::Client.new.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: messages,
          temperature: 1
        }
      )
    end
  end
end

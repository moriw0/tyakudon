module OmniAuthHelpers
  # rubocop:disable Naming/VariableNumber
  def set_omniauth(service = :google_oauth2)
    OmniAuth.config.mock_auth[service] = OmniAuth::AuthHash.new({
                                                                  provider: service.to_s,
                                                                  uid: '123456',
                                                                  info: {
                                                                    name: 'OAuth user',
                                                                    email: 'oauth@example.com'
                                                                  }
                                                                })
  end

  def set_invalid_omniauth(service = :google_oauth2)
    OmniAuth.config.mock_auth[service] = :invalid_credentials
  end
  # rubocop:enable Naming/VariableNumber
end

RSpec.configure do |config|
  OmniAuth.config.test_mode = true
  config.include OmniAuthHelpers
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
            Rails.application.credentials.dig(:gcp, :client_id),
            Rails.application.credentials.dig(:gcp, :client_secret)

  OmniAuth.config.on_failure =
    Proc.new { |env| SessionsController.action(:failure).call(env) }
end

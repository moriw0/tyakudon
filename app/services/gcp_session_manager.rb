class GcpSessionManager
  def self.new_session
    credentials = authenticate_with_google_auth

    GoogleDrive::Session.from_credentials(credentials)
  end

  def self.authenticate_with_google_auth
    credential_info = {
      client_id: Rails.application.credentials.dig(:gcp, :client_id),
      client_secret: Rails.application.credentials.dig(:gcp, :client_secret),
      refresh_token: Rails.application.credentials.dig(:gcp, :refresh_token)
    }

    Google::Auth::UserRefreshCredentials.new(credential_info).tap(&:fetch_access_token!)
  end
end

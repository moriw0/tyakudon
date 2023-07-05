require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "account_activation" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.account_activation(user) }

    before do
      user.activation_token = User.new_token
    end

    it "renders the headers" do
      expect(mail.subject).to eq("アカウントの有効化に関して")
      expect(mail.to).to eq(["user@example.com"])
      expect(mail.from).to eq(["tontonka2@gmail.com"])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to match(user.name)
      expect(mail.html_part.body.to_s).to match(user.activation_token)
      expect(mail.html_part.body.to_s).to match(CGI.escape(user.email))
    end
  end

  describe "password_reset"
end

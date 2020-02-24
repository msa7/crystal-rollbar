require "./spec_helper"

describe Rollbar do
  describe ".error" do
    it "send exception to Rollbar" do
      Rollbar.access_token = "token"
      Rollbar.environment = "test"
      Rollbar.framework = "Kemal"
      Rollbar.code_version = "0.1"

      # WebMock
      #   .stub(:post, "https://api.authy.com/protected")
      #   .with(body: "via=sms"})
      #   .to_return(body: %({"carrier":"Czech Republic"}))

      Rollbar.debug("Debug #{Time.utc}", user_id = "777")

      begin
        raise "Error #{Time.utc}"
      rescue e
        Rollbar.error(e, user_id = "555")
      end
    end
  end
end

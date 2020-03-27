module Rollbar::Sidekiq
  # Exception handler capturing all unhandled `Exception`s.
  #
  # ```
  # cli = Sidekiq::CLI.new
  # server = cli.configure do |config|
  #   # ...
  #   config.error_handlers << Rollbar::Sidekiq::ExceptionHandler.new
  # end
  # cli.run(server)
  # ```
  class ExceptionHandler < ::Sidekiq::ExceptionHandler::Base
    def call(ex : Exception, context : Hash(String, JSON::Any)? = nil)
      Rollbar.error(ex)
    end
  end
end

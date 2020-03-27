require "http"

class Rollbar::Kemal::ExceptionHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue exception
    Rollbar.error(exception)
    raise exception
  end
end

module Rollbar
  CONFIG_VARIABLES = [
    "access_token",
    "environment",
    "code_version",
    "framework",
  ]

  API_URI = URI.parse("https://api.rollbar.com/api/1/item/")

  {% for name in CONFIG_VARIABLES %}
    @@{{name.id}} : String?

    def self.{{name.id}}
      @@{{name.id}}
    end

    def self.{{name.id}}!
      @@{{name.id}}.not_nil!
    end

    def self.{{name.id}}?
      !@@{{name.id}}.nil?
    end

    def self.{{name.id}}=(new_value)
      @@{{name.id}} = new_value
    end
  {% end %}

  {% for name in ["debug", "info", "warning", "error", "critical"] %}
    def self.{{name.id}}(message, user_id = nil)
      headers = HTTP::Headers{"X-Rollbar-Access-Token" => Rollbar.access_token!}
      payload = Item.new(message, user_id, "{{name.id}}").payload
      response = HTTP::Client.post(API_URI, body: payload, headers: headers)

      # unless response.success?
      #   raise "Bad response from Rollbar. #{response}. Playload #{payload}"
      # end
    end
  {% end %}

  class Item
    @payload : String?
    @user_id : String?
    @level : String
    @message : String? = nil
    @exception : Exception? = nil

    def initialize(@exception : Exception, @user_id : String?, @level : String)
    end

    def initialize(@message : String, @user_id : String?, @level : String)
    end

    def payload
      @payload ||= build
    end

    private def build
      JSON.build do |json|
        json.object do
          json.field("access_token", Rollbar.access_token!)
          json.field("data") { json.object { build_data(json) } }
        end
      end
    end

    private def build_data(json)
      json.field("timestamp", Time.utc.to_unix)
      json.field("language", "crystal")
      json.field("uuid", UUID.random.to_s)
      json.field("level", @level)
      json.field("environment", Rollbar.environment!) if Rollbar.environment?
      json.field("code_version", Rollbar.code_version!) if Rollbar.code_version?
      json.field("framework", Rollbar.framework!) if Rollbar.framework?

      json.field("notifier") do
        json.object do
          json.field("name", "crystal-rollbar")
          json.field("version", "0.1")
        end
      end

      json.field("server") do
        json.object do
          json.field("host", System.hostname)
          json.field("pid", Process.pid)
        end
      end

      if @user_id
        json.field("person") do
          json.object do
            json.field("id", @user_id)
          end
        end
      end

      json.field("body") do
        json.object do
          if @exception
            build_exception_boby(json)
          else
            build_message_boby(json)
          end
        end
      end
    end

    private def build_message_boby(json)
      json.field("message") do
        json.object do
          json.field("body", @message.to_s)
        end
      end
    end

    private def build_exception_boby(json)
      exception = @exception.not_nil!

      json.field("trace") do
        json.object do
          json.field("exception") do
            json.object do
              json.field("class", exception.class.to_s)
              json.field("message", exception.message)
              json.field("description", exception.message)
            end

            build_exception_frames(json)
          end
        end
      end
    end

    private def build_exception_frames(json)
      backtrace = @exception.not_nil!.backtrace?
      return unless backtrace

      json.field("frames") do
        json.array do
          backtrace.each do |frame|
            json.object do
              json.field("filename", frame)

              filename_lineno_method = frame.split(" in '")

              if filename_lineno_method.size > 1
                filename, lineno, col = filename_lineno_method[0].split(":")
                method = filename_lineno_method[1].sub("'", "")
                json.field("lineno", lineno)
                json.field("method", method)
              end
            end
          end
        end
      end
    end
  end
end

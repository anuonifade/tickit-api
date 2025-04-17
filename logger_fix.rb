require "logger"

module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger unless defined?(Logger)
  end
end

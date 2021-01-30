module Sentry
  module Rails
    class CaptureExceptions < Sentry::Rack::CaptureExceptions
      private

      def transaction_op
        "rails.request".freeze
      end

      def capture_exception(exception)
        Sentry::Rails.capture_exception(exception)
      end
    end
  end
end

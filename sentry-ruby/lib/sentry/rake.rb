require "rake"
require "rake/task"

module Rake
  class Application

    alias orig_top_level top_level
    # we can't patch #run because the SDK might be initialized inside the Rakefile, which is loaded after #run is called.
    # #top_level handles the actual task execution.
    def top_level
      return orig_top_level unless Sentry.initialized? && Sentry.get_current_hub

      Sentry.get_current_hub.with_background_worker_disabled do
        orig_top_level
      end
    end

    alias orig_display_error_messsage display_error_message
    def display_error_message(ex)
      Sentry.capture_exception(ex, hint: { background: false }) do |scope|
        task_name = top_level_tasks.join(' ')
        scope.set_transaction_name(task_name)
        scope.set_tag("rake_task", task_name)
      end if Sentry.initialized? && !Sentry.configuration.skip_rake_integration

      orig_display_error_messsage(ex)
    end
  end
end

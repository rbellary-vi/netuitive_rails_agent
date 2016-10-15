require 'netuitive/rails_config_manager'

module RequestDataHook
  include ControllerUtils

  HEADERS_NAMES = [
    'HTTP_X_REQUEST_START'.freeze,
    'HTTP_X_QUEUE_START'.freeze,
    'HTTP_X_MIDDLEWARE_START'.freeze
  ].freeze

  def self.header_start_time(headers)
    if headers
      start_time = nil
      HEADERS_NAMES.each do |header_name|
        header = headers[header_name]
        next if header.nil?
        match = /\d+(\.\d{1,2})?/.match(header)
        if match.nil?
          NetuitiveLogger.log.error "queue time header value #{header} is not recognized"
          next
        end
        header_time = match.to_s.to_f / ConfigManager.queue_time_divisor
        NetuitiveLogger.log.debug "queue header_time: #{header_time}"
        start_time = start_time.nil? || header_time < start_time ? header_time : start_time
        NetuitiveLogger.log.debug "queue start_time: #{start_time}"
      end
      return (Time.now.to_f - start_time) * 1000.0
    end
    nil
  end

  def netuitive_request_hook
    return unless request
    begin
      queue_time = RequestDataHook.header_start_time(request.headers)
      NetuitiveLogger.log.debug "queue_time: #{queue_time}"
      NetuitiveLogger.log.debug 'sending queue_time metrics'
      NetuitiveRubyAPI.add_sample('action_controller.request.queue_time', queue_time)
      return unless netuitive_controller_name
      NetuitiveLogger.log.debug "sending queue_time metrics with netuitive_controller_name #{netuitive_controller_name}"
      NetuitiveRubyAPI.add_sample("action_controller.#{netuitive_controller_name}.request.queue_time", queue_time)
      return unless netuitive_action_name
      NetuitiveLogger.log.debug "sending queue_time metrics with netuitive_action_name #{netuitive_action_name}"
      NetuitiveRubyAPI.add_sample("action_controller.#{netuitive_controller_name}.#{netuitive_action_name}.request.queue_time", queue_time)
    rescue => e
      NetuitiveLogger.log.error "exception during request tracking: message:#{e.message} backtrace:#{e.backtrace}"
    end
  end
end

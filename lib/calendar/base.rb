# frozen_string_literal: true

module Calendar
  class Base
    PARAM_BLACKLIST = :token, :utf8, :_method, :script_name
    attr_accessor :view_context, :options

    def initialize(view_context, options = {}, &block)
      @view_context = view_context
      @locals = options.delete(:locals) || {}
      @options = options
      @block = block

      # next and previous should use the same params as the current view
      @params = @view_context.respond_to?(:params) ? @view_context.params : {}
      @params = @params.to_unsafe_h if @params.respond_to? :to_unsafe_h
      @params = @params.with_indifferent_access.except(*PARAM_BLACKLIST)

      # add any additional params the user provided
      @params.merge!(@options.fetch(:params, {}))
    end

    def render_in(view_context, &block)
      @block = block
      view_context.render(
        partial: partial_name,
        locals: locals
      )
    end

    def locals(&block)
      @locals.merge(
        passed_block: @block,
        calendar: self,
        date_range: date_range,
        start_date: start_date,
        sorted_events: sorted_events
      )
    end

    def classes_for_calendar_day(day)
      # today = Date.current
      today = Date.today
      # Always include: "relative py-2 px-3"
      div = ['relative py-2 px-3 min-h-24']
      time = ['']
      # Is current month, include: "bg-white"
      div << "bg-white dark:bg-gray-900 dark:text-white" if start_date.month == day.month
      # Is not current month, include: "bg-gray-50 text-gray-500"
      div << 'bg-gray-50 text-gray-500 dark:bg-gray-900' if start_date.month != day.month
      # Is today, include: "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white"
      time << 'flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white' if today == day
      div
      { div:, time: }
    end

    def url_for_next_view
      view_context.url_for(@params.merge(start_date_param => (date_range.last + 1.day).iso8601))
    end

    def url_for_previous_view
      view_context.url_for(@params.merge(start_date_param => (date_range.first - date_range.count.days).iso8601))
    end

    def url_for_today_view
      view_context.url_for(@params.merge(start_date_param => Time.current.to_date.iso8601))
    end

    def date_range
      (start_date..(start_date + additional_days.days)).to_a
    end

    def partial_name
      @options[:partial] || self.class.name.underscore
    end

    def attribute
      options.fetch(:attribute, :start_time).to_sym
    end

    def end_attribute
      options.fetch(:end_attribute, :end_time).to_sym
    end

    def start_date_param
      options.fetch(:start_date_param, :start_date).to_sym
    end

    def sorted_events
      @sorted_events ||= begin
                           events = Array.wrap(options[:events]).reject { |e| e.send(attribute).nil? }.sort_by(&attribute)
                           group_events_by_date(events)
                         end
    end

    def sorted_events_for(day)
      Array.wrap(sorted_events[day])
    end

    def group_events_by_date(events)
      events_grouped_by_date = Hash.new { |h, k| h[k] = [] }

      events.each do |event|
        event_start_date = event.send(attribute).to_date
        event_end_date = (event.respond_to?(end_attribute) && !event.send(end_attribute).nil?) ? event.send(end_attribute).to_date : event_start_date
        (event_start_date..event_end_date.to_date).each do |enumerated_date|
          events_grouped_by_date[enumerated_date] << event
        end
      end

      events_grouped_by_date
    end

    def start_date
      if options.has_key?(:start_date)
        options.fetch(:start_date).to_date
      else
        view_context.params.fetch(start_date_param, Date.current).to_date
      end
    end

    def end_date
      date_range.last
    end

    def additional_days
      options.fetch(:number_of_days, 4) - 1
    end

    def today_view_params
      { start_date_param => Time.current.to_date.iso8601 }
    end

  end
end

# frozen_string_literal: true

module Theme
  LIGHT = 'bg-white'.freeze
  DARK = 'dark:bg-gray-900'.freeze
  HTML_CLASS = "h-full #{LIGHT} #{DARK}".freeze
  BODY_CLASS = 'h-full'.freeze
  NAV_CLASS = "".freeze
  LIGHT_TEXT = "text-gray-900 placeholder:text-gray-400 ring-gray-300 focus:ring-indigo-600".freeze
  DARK_TEXT = "dark:bg-white/5 dark:text-white dark:ring-white/10 dark:focus:ring-indigo-500".freeze
  LIGHT_BTN = "bg-indigo-600 hover:bg-indigo-500 focus-visible:outline-indigo-600".freeze
  DARK_BTN = "dark:bg-indigo-500 dark:hover:bg-indigo-400 focus-visible:outline-indigo-500".freeze
  LIGHT_LABEL = "text-gray-900".freeze
  DARK_LABEL = "dark:text-white".freeze
  LIGHT_ANCHOR = "font-semibold leading-6 text-indigo-600 hover:text-indigo-500".freeze
  DARK_ANCHOR = "font-semibold leading-6 dark:text-indigo-400 dark:hover:text-indigo-300".freeze
  THEME_TEXT_STYLING = "#{LIGHT_TEXT} #{DARK_TEXT}".freeze
  THEME_BTN_STYLING = "#{LIGHT_BTN} #{DARK_BTN}".freeze
  THEME_LABEL_STYLING = "#{LIGHT_LABEL} #{DARK_LABEL}"
  THEME_ERROR_STYLING = 'mt-2 text-sm text-red-600'
  THEME_ANCHOR_STYLING = "#{LIGHT_ANCHOR} #{DARK_ANCHOR}"

  class FormBuilder < ActionView::Helpers::FormBuilder
    class_attribute :text_field_helpers, default: field_helpers - [:label, :check_box, :radio_button, :fields_for, :fields, :hidden_field, :file_field]
    #  leans on the FormBuilder class_attribute `field_helpers`
    #  you'll want to add a method for each of the specific helpers listed here if you want to style them

    # label
    # white
    # block text-sm font-medium leading-6 text-gray-900
    # dark
    # block text-sm font-medium leading-6 text-white

    # TEXT_FIELD_STYLE = "bg-gray-200 rounded py-2 px-4 text-gray-700 leading-tight focus:outline-none focus:bg-white".freeze
    TEXT_FIELD_STYLE = "block w-full rounded-md border-0 py-1.5 shadow-sm ring-1 ring-inset focus:ring-2 focus:ring-inset sm:text-sm sm:leading-6 #{THEME_TEXT_STYLING}".freeze
    SELECT_FIELD_STYLE = "block bg-gray-200 text-gray-700 py-2 px-4 rounded leading-tight focus:outline-none focus:bg-white".freeze
    # SUBMIT_BUTTON_STYLE = "shadow bg-yellow-800 focus:shadow-outline focus:outline-none text-white font-bold py-2 px-4 rounded hover:bg-yellow-700".freeze
    SUBMIT_BUTTON_STYLE = "flex w-full justify-center rounded-md px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 #{THEME_BTN_STYLING}".freeze

    text_field_helpers.each do |field_method|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{field_method}(method, options = {})
            if options.delete(:tailwindified)
              super
            else
              text_like_field(#{field_method.inspect}, method, options)
            end
          end
      RUBY_EVAL
    end

    def submit(value = nil, options = {})
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(SUBMIT_BUTTON_STYLE, custom_opts)

      super(value, { class: classes }.merge(opts))
    end

    def select(method, choices = nil, options = {}, html_options = {}, &block)
      custom_opts, opts = partition_custom_opts(options)
      classes = apply_style_classes(SELECT_FIELD_STYLE, custom_opts, method)

      labels = labels(method, custom_opts[:label], options)
      field = super(method, choices, opts, html_options.merge({ class: classes }), &block)

      labels + field
    end

    private

    def text_like_field(field_method, object_method, options = {})
      custom_opts, opts = partition_custom_opts(options)

      classes = apply_style_classes(TEXT_FIELD_STYLE, custom_opts, object_method)

      field = send(field_method, object_method, {
        class: classes,
        # title: errors_for(object_method)&.join(" ")
      }.compact.merge(opts).merge({ tailwindified: true }))

      labels = labels(object_method, custom_opts[:label], options)
      errors = error_msg(object_method, options)

      labels + field + errors
    end

    def labels(object_method, label_options, field_options)
      label = tailwind_label(object_method, label_options, field_options)
      # error_label = error_label(object_method, field_options)
      # @template.content_tag("div", label + error_label, { class: "flex flex-col items-start" })
      # @template.content_tag("div", label, { class: "flex flex-col items-start" })
    end

    def tailwind_label(object_method, label_options, field_options)
      text, label_opts = if label_options.present?
                           [label_options[:text], label_options.except(:text)]
                         else
                           [nil, {}]
                         end

      label_classes = label_opts[:class] || "block text-sm font-medium leading-6 #{THEME_LABEL_STYLING}"
      # label_classes = label_opts[:class] || "block text-gray-500 font-bold md:text-right mb-1 md:mb-0 pr-4"
      label_classes += " text-yellow-800 dark:text-yellow-400" if field_options[:disabled]
      # label_classes += " text-yellow-800 dark:text-yellow-400" if field_options[:disabled]
      label(object_method, text, {
        class: label_classes
      }.merge(label_opts.except(:class)))
    end

    def error_msg(object_method, options)
      errors = errors_for(object_method)
      if errors.present?
        # @template.content_tag :div, class: 'validation-errors' do
        msgs = []
        errors.full_messages_for(object_method).each do |msg|
          msgs << @template.content_tag(:p, msg, { class: THEME_ERROR_STYLING })
        end
        msgs.join.html_safe
        # end
      end
    end

    def error_label(object_method, options)
      if errors_for(object_method).present?
        error_message = @object.errors[object_method].collect(&:titleize).join(", ")
        tailwind_label(object_method, { text: error_message, class: " font-bold text-red-500" }, options)
      end
    end

    def border_color_classes(object_method)
      if errors_for(object_method).present?
        " border-2 border-red-400 focus:border-rose-200"
      else
        " border border-gray-300 focus:border-yellow-700"
      end
    end

    def apply_style_classes(classes, custom_opts, object_method = nil)
      classes + border_color_classes(object_method) + " #{custom_opts[:class]}"
    end

    CUSTOM_OPTS = [:label, :class].freeze

    def partition_custom_opts(opts)
      opts.partition { |k, v| CUSTOM_OPTS.include?(k) }.map(&:to_h)
    end

    def errors_for(object_method)
      return unless @object.present? && object_method.present? && @object.errors[object_method].present?

      @object.errors
    end

  end
end

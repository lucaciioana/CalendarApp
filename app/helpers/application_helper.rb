module ApplicationHelper
  ActionView::Base.default_form_builder = Theme::FormBuilder

  def grid(**options)
    defaults = {
      render_checkboxes: true,
      render_id: false,
      actions: { edit: true, delete: true },
      render_actions: true,
      title: 'DEBUG TITLE',
      desc: 'DEBUG DESC',
      headers: nil,
      data: nil,
      model: nil,
      show_path: nil,
      delete_path: nil
    }
    opts = defaults.merge(**options)
    opts[:headers] |= ['id'] if opts[:render_id] && opts[:headers].is_a?(Array)
    errors = []
    errors.push "Missing required parameter: data" if options[:data].nil?
    errors.push "Missing required parameter: headers" if options[:headers].blank?
    errors.push "Missing required parameter: model" if opts[:model].blank?
    opts[:model] = opts[:model].name.underscore unless opts[:model].is_a?(String)
    { partial: "shared/grid", locals: { **opts, errors: } }
  end

  def toast(**options)
    defaults = {
      auto_hide: true,
      duration: 5000,
      type: :success,
      color: 'text-gray-900'
    }
    if options[:type]
      case options[:type]
      when :error
        defaults[:color] = 'text-red-500'
      when :success
        defaults[:color] = 'text-green-500'
      end
    end
    opts = defaults.merge(**options)
    { partial: "shared/flash", locals: { **opts } }
  end

  def render_grid(**options)
    render grid(**options)
  end
end

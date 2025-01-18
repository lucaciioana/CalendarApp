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
      data: nil
    }
    opts = defaults.merge(**options)
    opts[:headers] |= ['id'] if opts[:render_id] && opts[:headers].is_a?(Array)
    errors = []
    errors.push "Missing required parameter: data" if options[:data].nil?
    errors.push "Missing required parameter: headers" if options[:headers].blank?

    render partial: "shared/grid", locals: { **opts, errors: }
  end
end

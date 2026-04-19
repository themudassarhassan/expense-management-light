# frozen_string_literal: true

module Breadcrumbs
  # Declarative entries for non-standard pages. Typical +resources :name+ controllers
  # are picked up automatically when +name_path+ exists.
  #
  # Options:
  # - :label — section or page title
  # - :index — path helper Symbol (e.g. :accounts_path), or nil for standalone pages
  # - :root_only — dashboard: only home, marked current
  # - :ivar — record instance variable if not +@#{controller_name.singularize}+
  SectionConfig = Struct.new(:label, :index, :root_only, :ivar, keyword_init: true)

  REGISTRY = {
    'home' => SectionConfig.new(label: nil, index: nil, root_only: true),
    'sessions' => SectionConfig.new(label: 'Sign in', index: nil),
    'registrations' => SectionConfig.new(label: 'Sign up', index: nil, ivar: :@user)
  }.freeze

  class Builder
    ACTION_FOR_BREADCRUMB = {
      'create' => 'new',
      'update' => 'edit'
    }.freeze

    Item = Struct.new(:home, :label, :url, :current, keyword_init: true)

    def initialize(view_context)
      @view = view_context
      @controller = view_context.controller
    end

    def items
      return [] if skip?

      crumbs = [Item.new(home: true, label: 'Home', url: @view.root_path, current: false)]
      section = section_config

      return home_only_trail(crumbs) if section&.root_only

      append_pages!(crumbs, section)
      mark_last_current!(crumbs)
      crumbs
    end

    private

    def skip?
      @controller.request.path == '/up'
    end

    def section_config
      name = @controller.controller_name
      return REGISTRY[name] if REGISTRY.key?(name)

      infer_section_config(name)
    end

    def infer_section_config(controller_name)
      path_helper = :"#{controller_name}_path"
      return unless @view.respond_to?(path_helper)

      SectionConfig.new(label: controller_name.humanize.titleize, index: path_helper)
    end

    def home_only_trail(crumbs)
      crumbs.first.current = true
      crumbs
    end

    def mapped_action
      ACTION_FOR_BREADCRUMB.fetch(@controller.action_name, @controller.action_name)
    end

    def append_pages!(crumbs, section)
      return if section.nil?

      action = mapped_action

      if section.index
        append_rest_pages!(crumbs, section, action)
      else
        append_standalone_pages!(crumbs, section, action)
      end
    end

    def append_rest_pages!(crumbs, section, action)
      case action
      when 'index'
        crumbs << Item.new(home: false, label: section.label, url: @view.public_send(section.index), current: false)
      when 'new'
        crumbs << Item.new(home: false, label: section.label, url: @view.public_send(section.index), current: false)
        crumbs << Item.new(home: false, label: new_action_label, url: nil, current: false)
      when 'show'
        crumbs << Item.new(home: false, label: section.label, url: @view.public_send(section.index), current: false)
        crumbs << Item.new(home: false, label: show_page_label, url: nil, current: false)
      when 'edit'
        crumbs << Item.new(home: false, label: section.label, url: @view.public_send(section.index), current: false)
        crumbs << Item.new(home: false, label: edit_page_label, url: nil, current: false)
      end
    end

    def append_standalone_pages!(crumbs, section, action)
      return unless %w[new create edit update].include?(action)

      crumbs << Item.new(home: false, label: section.label, url: nil, current: false)
    end

    def mark_last_current!(crumbs)
      return if crumbs.empty?

      crumbs.each { |c| c.current = false }
      crumbs.last.current = true
    end

    def new_action_label
      "#{I18n.t('helpers.breadcrumbs.new_prefix', default: 'New')} #{resource_model.model_name.human}"
    end

    def edit_page_label
      title = record_title
      title ? "Edit · #{title}" : "#{I18n.t('helpers.breadcrumbs.edit_prefix', default: 'Edit')} #{resource_model.model_name.human}"
    end

    def show_page_label
      record_title || "#{resource_model.model_name.human} ##{record&.id}"
    end

    def resource_model
      @controller.controller_name.classify.constantize
    end

    def record
      cfg = section_config
      return unless cfg&.index

      ivar = cfg.ivar || :"@#{@controller.controller_name.singularize}"
      @controller.instance_variable_get(ivar)
    end

    def record_title
      rec = record
      return unless rec

      case rec
      when Account
        rec.name
      when Transaction
        rec.description.presence || "#{rec.transaction_type.humanize} · #{@view.number_to_currency(rec.amount)}"
      when Budget
        month = rec.budget_month&.strftime('%B %Y')
        [rec.account&.name, month].compact.join(' · ').presence
      when User
        rec.name.presence || rec.email
      else
        if rec.respond_to?(:name) && rec.name.present?
          rec.name
        else
          "#{rec.class.model_name.human} ##{rec.id}"
        end
      end
    end
  end
end

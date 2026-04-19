# frozen_string_literal: true

module BreadcrumbsHelper
  def breadcrumb_items
    Breadcrumbs::Builder.new(self).items
  end
end

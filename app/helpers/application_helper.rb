# frozen_string_literal: true

module ApplicationHelper
  NAV_LINK_BASE = 'group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold'
  NAV_LINK_INACTIVE = 'text-gray-400 hover:bg-white/5 hover:text-white'
  NAV_LINK_ACTIVE = 'bg-white/5 text-white'

  def nav_link_to(path, prefix_match: false, **options, &block)
    is_active =
      if prefix_match
        path_str = path.to_s
        request.path == path_str || request.path.start_with?("#{path_str}/")
      else
        current_page?(path)
      end
    state = is_active ? NAV_LINK_ACTIVE : NAV_LINK_INACTIVE
    extra_class = options.delete(:class)
    link_classes = [NAV_LINK_BASE, state, extra_class].compact.join(' ')

    link_to path, options.merge(class: link_classes), &block
  end

  def form_page_width_classes
    'mx-auto max-w-2xl'
  end

  def form_back_link_classes
    'shrink-0 text-sm font-semibold text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300'
  end

  def form_card_classes
    'space-y-6 rounded-lg bg-white p-6 shadow-sm outline outline-1 outline-black/5 dark:bg-gray-800/50 dark:outline-white/10 sm:p-8'
  end

  def form_label_classes
    'block text-sm font-medium text-gray-900 dark:text-gray-200'
  end

  def form_control_classes
    'mt-1.5 block w-full rounded-md border-0 bg-white py-2 px-3 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-white/5 dark:text-white dark:ring-white/10 dark:placeholder:text-gray-500 dark:focus:ring-indigo-500'
  end

  def form_radio_classes
    'h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600 dark:border-white/10 dark:bg-white/5 dark:focus:ring-indigo-500'
  end

  def form_radio_label_classes
    'text-sm text-gray-700 dark:text-gray-300'
  end

  def form_submit_classes
    'inline-flex cursor-pointer justify-center rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500'
  end

  def form_secondary_actions_classes
    'flex flex-col-reverse gap-3 border-t border-gray-200 pt-6 dark:border-white/10 sm:flex-row sm:justify-end'
  end
end


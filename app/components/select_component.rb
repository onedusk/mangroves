# frozen_string_literal: true

class SelectComponent < Phlex::HTML
  def initialize(
    name:,
    options: [],
    selected: nil,
    placeholder: "Select an option",
    disabled: false,
    required: false,
    searchable: false,
    multiple: false,
    validation_state: nil,
    error_message: nil,
    hint: nil,
    label: nil,
    id: nil
  )
    @name = name
    @options = options
    @selected = selected
    @placeholder = placeholder
    @disabled = disabled
    @required = required
    @searchable = searchable
    @multiple = multiple
    @validation_state = validation_state
    @error_message = error_message
    @hint = hint
    @label = label
    @id = id || "select_#{name}"
  end

  def template
    div(class: "w-full") do
      if @label
        label(for: @id, class: "block text-sm font-medium text-gray-700 mb-1") do
          plain @label
          if @required
            span(class: "text-red-500 ml-1") { "*" }
          end
        end
      end

      if @searchable || @multiple
        render_custom_select
      else
        render_native_select
      end

      if @hint && !@error_message
        p(class: "mt-1 text-sm text-gray-500") { @hint }
      end

      if @error_message
        p(class: "mt-1 text-sm text-red-600", data: {select_target: "error"}) { @error_message }
      end
    end
  end

  private

  def render_native_select
    select(
      name: @name,
      id: @id,
      disabled: @disabled,
      required: @required,
      class: select_classes,
      data: {
        controller: "select",
        action: "change->select#validate"
      }
    ) do
      option(value: "", disabled: true, selected: @selected.nil?) { @placeholder }

      @options.each do |option|
        if option.is_a?(Hash)
          option(
            value: option[:value],
            selected: option[:value] == @selected
          ) { option[:label] }
        else
          option(value: option, selected: option == @selected) { option }
        end
      end
    end
  end

  def render_custom_select
    div(
      class: "relative",
      data: {
        controller: "select",
        select_multiple_value: @multiple,
        select_searchable_value: @searchable
      }
    ) do
      # Hidden input for form submission
      if @multiple
        input(type: "hidden", name: "#{@name}[]", value: "", disabled: @disabled)
        Array(@selected).each do |value|
          input(
            type: "hidden",
            name: "#{@name}[]",
            value: value,
            data: {select_target: "hiddenInput"}
          )
        end
      else
        input(
          type: "hidden",
          name: @name,
          value: @selected,
          data: {select_target: "hiddenInput"}
        )
      end

      # Trigger button
      button(
        type: "button",
        data: {
          action: "select#toggle",
          select_target: "trigger"
        },
        class: select_trigger_classes,
        disabled: @disabled
      ) do
        span(data: {select_target: "display"}, class: "block truncate") do
          if @multiple && @selected.present?
            "#{Array(@selected).length} selected"
          elsif @selected
            selected_label
          else
            span(class: "text-gray-500") { @placeholder }
          end
        end
        # Chevron icon
        svg(
          class: "h-5 w-5 text-gray-400",
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true"
        ) do
          path(
            fill_rule: "evenodd",
            d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
            clip_rule: "evenodd"
          )
        end
      end

      # Dropdown menu
      div(
        data: {select_target: "menu"},
        class: "hidden absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm"
      ) do
        if @searchable
          div(class: "sticky top-0 bg-white px-2 py-2 border-b") do
            input(
              type: "text",
              placeholder: "Search...",
              data: {
                action: "input->select#search",
                select_target: "searchInput"
              },
              class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
            )
          end
        end

        div(data: {select_target: "options"}) do
          @options.each do |option|
            render_option(option)
          end
        end
      end
    end
  end

  def render_option(option)
    value = option.is_a?(Hash) ? option[:value] : option
    label = option.is_a?(Hash) ? option[:label] : option
    is_selected = if @multiple
                    Array(@selected).include?(value)
                  else
                    value == @selected
                  end

    div(
      data: {
        action: "click->select#selectOption",
        select_target: "option",
        value: value,
        label: label
      },
      class: "#{option_classes} #{is_selected ? "bg-blue-50 text-blue-900" : "text-gray-900"}"
    ) do
      div(class: "flex items-center justify-between") do
        span(class: "block truncate #{is_selected ? "font-semibold" : "font-normal"}") { label }
        if is_selected
          svg(
            class: "h-5 w-5 text-blue-600",
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 20 20",
            fill: "currentColor",
            aria_hidden: "true"
          ) do
            path(
              fill_rule: "evenodd",
              d: "M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z",
              clip_rule: "evenodd"
            )
          end
        end
      end
    end
  end

  def selected_label
    option = @options.find do |opt|
      opt.is_a?(Hash) ? opt[:value] == @selected : opt == @selected
    end

    if option.is_a?(Hash)
      option[:label]
    else
      option || @placeholder
    end
  end

  def select_classes
    base = "block w-full rounded-md shadow-sm sm:text-sm"
    base += " focus:outline-none focus:ring-2"

    case @validation_state
    when :error
      "#{base} border-red-300 text-red-900 focus:ring-red-500 focus:border-red-500"
    when :success
      "#{base} border-green-300 text-green-900 focus:ring-green-500 focus:border-green-500"
    else
      "#{base} border-gray-300 focus:ring-blue-500 focus:border-blue-500"
    end + (@disabled ? " bg-gray-100 cursor-not-allowed" : "")
  end

  def select_trigger_classes
    base = "relative w-full cursor-default rounded-md border bg-white py-2 pl-3 pr-10 text-left shadow-sm"
    base += " focus:outline-none focus:ring-2 sm:text-sm"

    case @validation_state
    when :error
      "#{base} border-red-300 focus:ring-red-500 focus:border-red-500"
    when :success
      "#{base} border-green-300 focus:ring-green-500 focus:border-green-500"
    else
      "#{base} border-gray-300 focus:ring-blue-500 focus:border-blue-500"
    end + (@disabled ? " bg-gray-100 cursor-not-allowed" : "")
  end

  def option_classes
    "cursor-default select-none relative py-2 pl-3 pr-9 hover:bg-gray-50"
  end
end

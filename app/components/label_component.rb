# frozen_string_literal: true

class LabelComponent < ApplicationComponent
  def initialize(
    text:,
    for_id:,
    required: false,
    optional: false,
    size: :default,
    tooltip: nil
  )
    @text = text
    @for_id = for_id
    @required = required
    @optional = optional
    @size = size
    @tooltip = tooltip
  end

  def view_template
    label(
      for: @for_id,
      class: label_classes,
      data: label_data
    ) do
      plain @text

      if @required
        span(class: "text-red-500 ml-1") { "*" }
      end

      if @optional
        span(class: "text-gray-500 text-xs ml-1 font-normal") { "(optional)" }
      end

      if @tooltip
        span(
          class: "ml-1 inline-flex items-center",
          data: {
            controller: "tooltip",
            tooltip_text_value: sanitize_text(@tooltip)
          }
        ) do
          svg(
            class: "w-4 h-4 text-gray-400 hover:text-gray-600 cursor-help",
            fill: "currentColor",
            viewBox: "0 0 20 20",
            xmlns: "http://www.w3.org/2000/svg"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z",
              clip_rule: "evenodd"
            )
          end
        end
      end
    end
  end

  private

  def label_classes
    base = "block font-medium text-gray-700"

    size_class = case @size
                 when :sm
                   "text-xs"
                 when :lg
                   "text-base"
                 else
                   "text-sm"
                 end

    "#{base} #{size_class}"
  end

  def label_data
    return {} unless @tooltip

    {
      controller: "label",
      action: "mouseenter->label#showTooltip mouseleave->label#hideTooltip"
    }
  end
end

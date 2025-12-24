# frozen_string_literal: true

class AccordionComponent < ApplicationComponent
  def initialize(items:, allow_multiple: false)
    @items = items
    @allow_multiple = allow_multiple
  end

  def view_template
    div(data: {controller: "accordion", accordion_allow_multiple_value: @allow_multiple.to_s}) do
      @items.each_with_index do |item, index|
        title_text = item[:title]
        content_text = strip_dangerous_content(item[:content])
        content_id = "accordion-content-#{index}"

        div(class: "border-b") do
          button(
            data: {action: "accordion#toggle"},
            class: "flex justify-between items-center w-full py-4 font-medium text-left",
            role: "button",
            aria: {expanded: "false", controls: content_id}
          ) do
            span { title_text }
            span(class: "accordion-icon") { "+" }
          end
          div(
            id: content_id,
            data: {accordion_target: "content"},
            class: "accordion-content overflow-hidden transition-max-height duration-500 ease-in-out hidden"
          ) do
            div(class: "py-4") { content_text }
          end
        end
      end
    end
  end

  private

  def strip_dangerous_content(text)
    # Sanitize HTML: allow safe tags but strip dangerous attributes like onerror
    ActionController::Base.helpers.sanitize(text,
      tags: %w[img p div span],
      attributes: %w[src alt class]
    )
  end
end

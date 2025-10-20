# frozen_string_literal: true

class AccordionComponent < Phlex::HTML
  def initialize(items)
    @items = items
  end

  def template
    div(data: {controller: "accordion"}) do
      @items.each_with_index do |item, _index|
        div(class: "border-b") do
          button(
            data: {action: "accordion#toggle"},
            class: "flex justify-between items-center w-full py-4 font-medium text-left"
          ) do
            span { item[:title] }
            span(class: "accordion-icon") { "+" }
          end
          div(
            data: {accordion_target: "content"},
            class: "accordion-content overflow-hidden transition-max-height duration-500 ease-in-out"
          ) do
            div(class: "py-4") { item[:content] }
          end
        end
      end
    end
  end
end

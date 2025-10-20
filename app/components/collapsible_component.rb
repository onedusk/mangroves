# frozen_string_literal: true

class CollapsibleComponent < Phlex::HTML
  def initialize(title:)
    @title = title
  end

  def template(&)
    div(data: {controller: "collapsible"}) do
      button(
        data: {action: "collapsible#toggle"},
        class: "flex justify-between items-center w-full py-4 font-medium text-left"
      ) do
        span { @title }
        span(class: "collapsible-icon") { "+" }
      end
      div(
        data: {collapsible_target: "content"},
        class: "collapsible-content overflow-hidden transition-max-height duration-500 ease-in-out"
      ) do
        div(class: "py-4", &)
      end
    end
  end
end

# frozen_string_literal: true

class SheetComponent < Phlex::HTML
  def initialize(title:, side: "right")
    @title = title
    @side = side
  end

  def view_template(&)
    div(
      data: {
        controller: "sheet",
        sheet_side_value: @side
      },
      class: "fixed inset-0 z-50 overflow-hidden"
    ) do
      # Backdrop
      div(
        data: {action: "click->sheet#close"},
        class: "absolute inset-0 bg-gray-900 bg-opacity-50 transition-opacity"
      )

      # Sheet panel
      div(class: sheet_container_classes) do
        div(
          data: {sheet_target: "panel"},
          class: sheet_panel_classes
        ) do
          div(class: "h-full flex flex-col bg-white shadow-xl") do
            # Header
            div(class: "px-4 py-6 sm:px-6 border-b border-gray-200") do
              div(class: "flex items-start justify-between") do
                h2(class: "text-lg font-semibold text-gray-900") { @title }
                button(
                  data: {action: "sheet#close"},
                  class: "ml-3 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 rounded-md"
                ) do
                  span(class: "sr-only") { "Close panel" }
                  svg(
                    class: "h-6 w-6",
                    fill: "none",
                    viewBox: "0 0 24 24",
                    stroke: "currentColor",
                    aria_hidden: "true"
                  ) do |s|
                    s.path(
                      stroke_linecap: "round",
                      stroke_linejoin: "round",
                      stroke_width: "2",
                      d: "M6 18L18 6M6 6l12 12"
                    )
                  end
                end
              end
            end

            # Content
            div(class: "flex-1 overflow-y-auto px-4 py-6 sm:px-6", &)
          end
        end
      end
    end
  end

  private

  def sheet_container_classes
    case @side
    when "left"
      "absolute inset-y-0 left-0 pr-10 max-w-full flex"
    when "right"
      "absolute inset-y-0 right-0 pl-10 max-w-full flex"
    when "top"
      "absolute inset-x-0 top-0 pb-10 max-h-full flex flex-col"
    when "bottom"
      "absolute inset-x-0 bottom-0 pt-10 max-h-full flex flex-col"
    end
  end

  def sheet_panel_classes
    base_classes = "transform transition ease-in-out duration-500"

    case @side
    when "left"
      "#{base_classes} w-screen max-w-md"
    when "right"
      "#{base_classes} w-screen max-w-md"
    when "top"
      "#{base_classes} h-screen max-h-md"
    when "bottom"
      "#{base_classes} h-screen max-h-md"
    end
  end
end

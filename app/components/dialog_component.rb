# frozen_string_literal: true

class DialogComponent < Phlex::HTML
  def initialize(title:)
    @title = title
  end

  def template(&)
    div(
      data: {controller: "dialog"},
      class: "fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center"
    ) do
      div(class: "bg-white rounded-lg shadow-xl p-6 w-full max-w-md") do
        div(class: "flex justify-between items-center") do
          h3(class: "text-lg font-medium leading-6 text-gray-900") { @title }
          button(data: {action: "dialog#close"}, class: "text-gray-400 hover:text-gray-500") do
            svg(class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
              path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M6 18L18 6M6 6l12 12")
            end
          end
        end
        div(class: "mt-4", &)
      end
    end
  end
end

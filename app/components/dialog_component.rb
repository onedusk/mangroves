# frozen_string_literal: true

class DialogComponent < ApplicationComponent
  def initialize(title:)
    @title = title
    @title_id = "dialog_title_#{SecureRandom.hex(8)}"
  end

  def view_template(&)
    div(
      data: {controller: "dialog"},
      role: "dialog",
      aria: {
        modal: "true",
        labelledby: @title_id
      },
      class: "fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center"
    ) do
      div(class: "bg-white rounded-lg shadow-xl p-6 w-full max-w-md") do
        div(class: "flex justify-between items-center") do
          h3(id: @title_id, class: "text-lg font-medium leading-6 text-gray-900") { plain @title }
          button(
            data: {action: "dialog#close"},
            aria: {label: "Close dialog"},
            class: "text-gray-400 hover:text-gray-500"
          ) do
            svg(class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", aria: {hidden: "true"}) do
              path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M6 18L18 6M6 6l12 12")
            end
          end
        end
        div(class: "mt-4", &)
      end
    end
  end
end

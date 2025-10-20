# frozen_string_literal: true

class AlertDialogComponent < Phlex::HTML
  def initialize(title:, content:, cancel_text: "Cancel", continue_text: "Continue")
    @title = title
    @content = content
    @cancel_text = cancel_text
    @continue_text = continue_text
  end

  def template
    div(
      data: {controller: "alert-dialog"},
      class: "fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center"
    ) do
      div(class: "bg-white rounded-lg shadow-xl p-6 w-full max-w-md") do
        h3(class: "text-lg font-medium leading-6 text-gray-900") { @title }
        div(class: "mt-2") do
          p(class: "text-sm text-gray-500") { @content }
        end
        div(class: "mt-4 flex justify-end space-x-2") do
          button(data: {action: "alert-dialog#cancel"}, class: "px-4 py-2 bg-gray-200 text-gray-800 rounded-md") do
            @cancel_text
          end
          button(data: {action: "alert-dialog#continue"}, class: "px-4 py-2 bg-red-600 text-white rounded-md") do
            @continue_text
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class AlertDialogComponent < ApplicationComponent
  def initialize(title:, content:, cancel_text: "Cancel", continue_text: "Continue")
    @title = title
    @content = content
    @cancel_text = cancel_text
    @continue_text = continue_text
    @title_id = "alert_dialog_title_#{SecureRandom.hex(8)}"
    @desc_id = "alert_dialog_desc_#{SecureRandom.hex(8)}"
  end

  def view_template
    div(
      data: {controller: "alert-dialog"},
      role: "alertdialog",
      aria: {
        modal: "true",
        labelledby: @title_id,
        describedby: @desc_id
      },
      class: "fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center"
    ) do
      div(class: "bg-white rounded-lg shadow-xl p-6 w-full max-w-md") do
        h3(id: @title_id, class: "text-lg font-medium leading-6 text-gray-900") { plain @title }
        div(class: "mt-2") do
          p(id: @desc_id, class: "text-sm text-gray-500") { plain @content }
        end
        div(class: "mt-4 flex justify-end space-x-2") do
          button(data: {action: "alert-dialog#cancel"}, class: "px-4 py-2 bg-gray-200 text-gray-800 rounded-md") do
            plain @cancel_text
          end
          button(data: {action: "alert-dialog#continue"}, class: "px-4 py-2 bg-red-600 text-white rounded-md") do
            plain @continue_text
          end
        end
      end
    end
  end
end

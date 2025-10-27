# frozen_string_literal: true

class AlertComponent < ApplicationComponent
  def initialize(message, type: :info)
    @message = message
    @type = type
  end

  def view_template
    div(class: "#{alert_classes} p-4 rounded-md") do
      p { @message }
    end
  end

  private

  def alert_classes
    case @type
    when :success
      "bg-green-100 text-green-800"
    when :error
      "bg-red-100 text-red-800"
    when :warning
      "bg-yellow-100 text-yellow-800"
    else
      "bg-blue-100 text-blue-800"
    end
  end
end

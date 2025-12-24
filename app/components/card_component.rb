# frozen_string_literal: true

class CardComponent < ApplicationComponent
  def initialize(title: nil, footer: nil, padding: :normal, hoverable: false)
    @title = title
    @footer = footer
    @padding = padding
    @hoverable = hoverable
  end

  def view_template(&)
    div(class: card_classes) do
      if @title
        div(class: "p-4 border-b") do
          h5(class: "text-xl font-bold tracking-tight text-gray-900") { @title }
        end
      end
      div(class: content_padding_classes, &)
      if @footer
        div(class: "p-4 border-t") do
          # Sanitize to remove dangerous HTML while allowing safe tags
          plain strip_dangerous_content(@footer)
        end
      end
    end
  end

  private

  def card_classes
    base = "bg-white border border-gray-200 rounded-lg shadow"
    base += " hover:shadow-lg transition-shadow duration-200" if @hoverable
    base
  end

  def content_padding_classes
    case @padding
    when :none
      ""
    when :small
      "p-2"
    when :large
      "p-6"
    else
      "p-4"
    end
  end

  def strip_dangerous_content(text)
    # Sanitize HTML: allow img tags but strip dangerous attributes like onerror
    ActionController::Base.helpers.sanitize(text.to_s,
      tags: %w[img p div span],
      attributes: %w[src alt class])
  end
end

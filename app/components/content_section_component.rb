# frozen_string_literal: true

class ContentSectionComponent < ApplicationComponent
  def initialize(
    container: :default,
    padding: :default,
    background: :white,
    id: nil,
    class_name: nil
  )
    @container = container
    @padding = padding
    @background = background
    @id = id
    @class_name = class_name
  end

  def view_template(&)
    section(id: @id, class: "#{background_classes} #{@class_name}") do
      div(class: container_classes) do
        div(class: padding_classes, &)
      end
    end
  end

  private

  def container_classes
    case @container
    when :narrow
      "max-w-4xl mx-auto px-4 sm:px-6 lg:px-8"
    when :wide
      "max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8"
    when :full
      "w-full px-4 sm:px-6 lg:px-8"
    when :none
      "w-full"
    else
      "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
    end
  end

  def padding_classes
    case @padding
    when :none
      ""
    when :sm
      "py-4 sm:py-6 lg:py-8"
    when :lg
      "py-16 sm:py-20 lg:py-24"
    when :xl
      "py-20 sm:py-24 lg:py-32"
    else
      "py-8 sm:py-12 lg:py-16"
    end
  end

  def background_classes
    case @background
    when :gray
      "bg-gray-50"
    when :dark
      "bg-gray-900"
    when :primary
      "bg-blue-600"
    when :transparent
      "bg-transparent"
    else
      "bg-white"
    end
  end
end

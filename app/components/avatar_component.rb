# frozen_string_literal: true

class AvatarComponent < Phlex::HTML
  def initialize(src: nil, initials: nil, size: :md)
    @src = src
    @initials = initials
    @size = size
  end

  def template
    span(class: "#{size_classes} rounded-full flex items-center justify-center bg-gray-200 text-gray-500") do
      if @src
        img(src: @src, class: "rounded-full")
      else
        @initials
      end
    end
  end

  private

  def size_classes
    case @size
    when :sm
      "h-8 w-8 text-xs"
    when :lg
      "h-16 w-16 text-xl"
    else
      "h-12 w-12 text-base"
    end
  end
end

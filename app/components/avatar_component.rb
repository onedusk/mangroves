# frozen_string_literal: true

class AvatarComponent < ApplicationComponent
  def initialize(src: nil, initials: nil, alt: nil, size: :md)
    @src = src
    @initials = initials
    @alt = alt
    @size = size
  end

  def view_template
    span(class: "#{size_classes} rounded-full flex items-center justify-center bg-gray-200 text-gray-500") do
      if @src
        img(src: sanitized_src, alt: escaped_alt, class: "rounded-full")
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

  def sanitized_src
    # Remove javascript: protocol for security
    return nil if @src.nil?
    @src.to_s.start_with?("javascript:") ? nil : @src
  end

  def escaped_alt
    # Explicitly escape HTML in alt text for security
    return nil if @alt.nil?
    ERB::Util.html_escape(@alt)
  end
end

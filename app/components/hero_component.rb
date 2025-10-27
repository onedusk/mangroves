# frozen_string_literal: true

class HeroComponent < ApplicationComponent
  def initialize(
    title:,
    subtitle: nil,
    primary_cta: nil,
    secondary_cta: nil,
    background_image: nil,
    background_color: :gradient,
    text_alignment: :center,
    height: :default
  )
    @title = title
    @subtitle = subtitle
    @primary_cta = primary_cta
    @secondary_cta = secondary_cta
    @background_image = background_image
    @background_color = background_color
    @text_alignment = text_alignment
    @height = height
  end

  def view_template
    section(class: "relative #{height_classes} #{background_classes}") do
      render_background_overlay if @background_image
      render_hero_content
    end
  end

  private

  def height_classes
    case @height
    when :sm
      "min-h-[40vh]"
    when :lg
      "min-h-[80vh]"
    when :full
      "min-h-screen"
    else
      "min-h-[60vh]"
    end
  end

  def background_classes
    if @background_image
      "bg-cover bg-center bg-no-repeat"
    else
      case @background_color
      when :primary
        "bg-blue-600"
      when :dark
        "bg-gray-900"
      when :gradient
        "bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-800"
      else
        "bg-white"
      end
    end
  end

  def render_background_overlay
    # NOTE: XSS Protection - Sanitize background image URL
    safe_bg_url = safe_url(@background_image)
    div(
      class: "absolute inset-0 bg-black bg-opacity-50",
      style: safe_bg_url ? "background-image: url(#{safe_bg_url});" : nil
    )
  end

  def render_hero_content
    div(class: "relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center") do
      div(class: "#{text_alignment_classes} w-full") do
        render_title
        render_subtitle
        render_cta_buttons
      end
    end
  end

  def text_alignment_classes
    case @text_alignment
    when :left
      "text-left"
    when :right
      "text-right ml-auto max-w-2xl"
    else
      "text-center mx-auto max-w-4xl"
    end
  end

  def render_title
    h1(class: title_classes) { plain @title }
  end

  def title_classes
    base = "font-bold tracking-tight mb-4 sm:mb-6"
    color = @background_color == :gradient || @background_image ? "text-white" : "text-gray-900"
    size = "text-4xl sm:text-5xl md:text-6xl lg:text-7xl"
    "#{base} #{color} #{size}"
  end

  def render_subtitle
    return unless @subtitle

    p(class: subtitle_classes) { plain @subtitle }
  end

  def subtitle_classes
    base = "mb-8 sm:mb-10 max-w-2xl"
    color = @background_color == :gradient || @background_image ? "text-gray-200" : "text-gray-600"
    size = "text-lg sm:text-xl md:text-2xl"
    margin = @text_alignment == :center ? "mx-auto" : ""
    "#{base} #{color} #{size} #{margin}"
  end

  def render_cta_buttons
    return unless @primary_cta || @secondary_cta

    div(class: "flex flex-col sm:flex-row gap-4 #{button_alignment_classes}") do
      render_primary_cta if @primary_cta
      render_secondary_cta if @secondary_cta
    end
  end

  def button_alignment_classes
    case @text_alignment
    when :left
      "justify-start"
    when :right
      "justify-end"
    else
      "justify-center"
    end
  end

  def render_primary_cta
    a(
      href: safe_url(@primary_cta[:url]),
      class: "inline-flex items-center justify-center px-6 sm:px-8 py-3 sm:py-4 " \
             "text-base sm:text-lg font-medium rounded-lg text-white bg-blue-600 " \
             "hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-300 " \
             "transition-colors duration-200"
    ) { plain @primary_cta[:text] }
  end

  def render_secondary_cta
    a(
      href: safe_url(@secondary_cta[:url]),
      class: "inline-flex items-center justify-center px-6 sm:px-8 py-3 sm:py-4 " \
             "text-base sm:text-lg font-medium rounded-lg " \
             "#{secondary_cta_color_classes} " \
             "focus:outline-none focus:ring-4 focus:ring-gray-300 " \
             "transition-colors duration-200"
    ) { plain @secondary_cta[:text] }
  end

  def secondary_cta_color_classes
    if @background_color == :gradient || @background_image
      "text-white border-2 border-white hover:bg-white hover:text-gray-900"
    else
      "text-gray-900 border-2 border-gray-900 hover:bg-gray-900 hover:text-white"
    end
  end
end

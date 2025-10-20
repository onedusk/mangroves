# frozen_string_literal: true

class SonnerComponent < Phlex::HTML
  def initialize(
    message:,
    variant: :info,
    duration: 5000,
    action_label: nil,
    action_url: nil,
    undo_callback: nil,
    dismissible: true
  )
    @message = message
    @variant = variant
    @duration = duration
    @action_label = action_label
    @action_url = action_url
    @undo_callback = undo_callback
    @dismissible = dismissible
  end

  def view_template
    div(
      class: "sonner #{base_classes} #{variant_classes}",
      data: {
        controller: "sonner",
        sonner_duration_value: @duration,
        sonner_undo_callback_value: @undo_callback
      },
      role: "alert"
    ) do
      div(class: "flex items-start gap-3") do
        render_icon
        div(class: "flex-1 min-w-0") do
          p(class: "text-sm font-medium") { @message }
          render_actions if @action_label || @undo_callback
        end
        render_dismiss_button if @dismissible
      end
      render_progress_bar
    end
  end

  private

  def base_classes
    "pointer-events-auto w-full max-w-md rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 p-4 overflow-hidden"
  end

  def variant_classes
    case @variant
    when :success
      "bg-green-50 text-green-800 ring-green-200"
    when :error
      "bg-red-50 text-red-800 ring-red-200"
    when :warning
      "bg-yellow-50 text-yellow-800 ring-yellow-200"
    when :promise
      "bg-blue-50 text-blue-800 ring-blue-200"
    else
      "bg-white text-gray-800 ring-gray-200"
    end
  end

  def render_icon
    svg_class = case @variant
                when :success then "text-green-400"
                when :error then "text-red-400"
                when :warning then "text-yellow-400"
                when :promise then "text-blue-400 animate-spin"
                else "text-gray-400"
                end

    raw <<~HTML
      <svg class="h-5 w-5 flex-shrink-0 #{svg_class}" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="#{icon_path}" clip-rule="evenodd" />
      </svg>
    HTML
  end

  def icon_path
    case @variant
    when :success
      "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
    when :error
      "M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
    when :warning
      "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
    when :promise
      "M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707z"
    else
      "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
    end
  end

  def render_actions
    div(class: "flex items-center gap-3 mt-2") do
      if @undo_callback
        button(
          type: "button",
          data: {action: "sonner#undo"},
          class: "text-sm font-medium underline hover:no-underline focus:outline-none"
        ) { "Undo" }
      end

      if @action_label && @action_url
        a(
          href: @action_url,
          class: "text-sm font-medium underline hover:no-underline focus:outline-none"
        ) { @action_label }
      end
    end
  end

  def render_dismiss_button
    button(
      type: "button",
      data: {action: "sonner#dismiss"},
      class: "inline-flex rounded-md p-1.5 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
    ) do
      span(class: "sr-only") { "Dismiss" }
      raw <<~HTML
        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      HTML
    end
  end

  def render_progress_bar
    return unless @duration > 0

    div(
      class: "absolute bottom-0 left-0 h-1 bg-current opacity-20",
      data: {sonner_target: "progress"},
      style: "width: 100%; animation: sonner-progress #{@duration}ms linear;"
    )
  end
end

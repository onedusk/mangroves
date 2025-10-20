# frozen_string_literal: true

class ResizableComponent < Phlex::HTML
  def initialize(orientation: :horizontal, default_size: 50, min_size: 20, max_size: 80)
    @orientation = orientation
    @default_size = default_size
    @min_size = min_size
    @max_size = max_size
  end

  def view_template(&block)
    div(
      data: {
        controller: "resizable",
        resizable_orientation_value: @orientation,
        resizable_default_size_value: @default_size,
        resizable_min_size_value: @min_size,
        resizable_max_size_value: @max_size
      },
      class: "resizable-container #{container_classes}"
    ) do
      div(
        data: {resizable_target: "panel1"},
        class: "resizable-panel overflow-auto",
        style: panel1_style
      ) do
        yield :panel1 if block
      end

      div(
        data: {
          resizable_target: "handle",
          action: "mousedown->resizable#startResize touchstart->resizable#startResize"
        },
        class: "resizable-handle #{handle_classes}"
      ) do
        div(class: "resizable-handle-indicator #{indicator_classes}")
      end

      div(
        data: {resizable_target: "panel2"},
        class: "resizable-panel overflow-auto"
      ) do
        yield :panel2 if block
      end
    end
  end

  private

  def container_classes
    @orientation == :vertical ? "flex flex-col h-full" : "flex flex-row h-full"
  end

  def handle_classes
    if @orientation == :vertical
      "cursor-row-resize h-2 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 flex items-center justify-center"
    else
      "cursor-col-resize w-2 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 flex items-center justify-center"
    end
  end

  def indicator_classes
    if @orientation == :vertical
      "w-8 h-1 rounded-full bg-gray-400 dark:bg-gray-500"
    else
      "h-8 w-1 rounded-full bg-gray-400 dark:bg-gray-500"
    end
  end

  def panel1_style
    if @orientation == :vertical
      "height: #{@default_size}%"
    else
      "width: #{@default_size}%"
    end
  end
end

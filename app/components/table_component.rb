# frozen_string_literal: true

class TableComponent < ApplicationComponent
  def initialize(
    data: [],
    columns: [],
    sortable: false,
    selectable: false,
    paginated: false,
    per_page: 10,
    current_page: 1,
    striped: true,
    hoverable: true,
    class_name: nil,
    skip_tenant_check: false
  )
    @data = data
    @columns = columns
    @sortable = sortable
    @selectable = selectable
    @paginated = paginated
    @per_page = per_page
    @current_page = current_page
    @striped = striped
    @hoverable = hoverable
    @class_name = class_name
    @skip_tenant_check = skip_tenant_check

    # SECURITY: Validate all tenant-scoped records belong to Current.account
    validate_tenant_isolation! unless @skip_tenant_check
  end

  def view_template
    div(
      data: {
        controller: "table",
        table_sortable_value: @sortable,
        table_selectable_value: @selectable
      },
      class: "table-container w-full #{@class_name}".strip
    ) do
      # Table wrapper for horizontal scroll
      div(class: "overflow-x-auto") do
        table(class: "w-full text-sm text-left text-gray-500 dark:text-gray-400") do
          render_thead
          render_tbody
        end
      end

      # Pagination if enabled
      if @paginated
        render_pagination
      end

      # Selection summary if selectable
      if @selectable
        div(
          data: {table_target: "selectionSummary"},
          class: "hidden mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg"
        ) do
          span(data: {table_target: "selectionCount"}, class: "text-sm font-medium text-blue-900 dark:text-blue-100")
        end
      end
    end
  end

  private

  def render_thead
    thead(class: "text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400") do
      tr do
        # Selection column
        if @selectable
          th(scope: "col", class: "p-4") do
            div(class: "flex items-center") do
              input(
                type: "checkbox",
                data: {
                  table_target: "selectAll",
                  action: "change->table#toggleAll"
                },
                class: "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
              )
            end
          end
        end

        # Data columns
        @columns.each do |column|
          render_th(column)
        end
      end
    end
  end

  def render_th(column)
    col_key = column.is_a?(Hash) ? column[:key] : column
    col_label = column.is_a?(Hash) ? column[:label] : column.to_s.titleize
    sortable = @sortable && (!column.is_a?(Hash) || column[:sortable] != false)

    th(scope: "col", class: "px-6 py-3") do
      if sortable
        button(
          type: "button",
          data: {
            table_target: "sortHeader",
            action: "click->table#sort",
            column: col_key
          },
          class: "flex items-center gap-2 hover:text-gray-900 dark:hover:text-white"
        ) do
          span { col_label }
          span(
            data: {table_target: "sortIcon"},
            class: "sort-icon text-gray-400"
          ) { "↕" }
        end
      else
        span { col_label }
      end
    end
  end

  def render_tbody
    tbody do
      if @data.empty?
        render_empty_state
      else
        paginated_data.each_with_index do |row, index|
          render_row(row, index)
        end
      end
    end
  end

  def render_row(row, index)
    tr(
      data: {table_target: "row"},
      class: "#{row_classes(index)} border-b dark:border-gray-700"
    ) do
      # Selection cell
      if @selectable
        td(class: "w-4 p-4") do
          div(class: "flex items-center") do
            input(
              type: "checkbox",
              data: {
                table_target: "rowCheckbox",
                action: "change->table#toggleRow",
                row_id: row_id(row)
              },
              class: "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            )
          end
        end
      end

      # Data cells
      @columns.each do |column|
        render_td(row, column)
      end
    end
  end

  def render_td(row, column)
    col_key = column.is_a?(Hash) ? column[:key] : column
    value = row.is_a?(Hash) ? row[col_key] : row.send(col_key)

    # Format value if formatter provided
    if column.is_a?(Hash) && column[:format]
      value = column[:format].call(value, row)
    end

    td(class: "px-6 py-4") do
      # SECURITY: Only allow Phlex components or sanitize everything else
      case value
      when String, Numeric
        plain value.to_s
      when Phlex::HTML
        value # Allow explicit Phlex component rendering
      when NilClass
        plain "" # Render empty string for nil
      else
        plain value.to_s # Force string conversion and escape for all other types
      end
    end
  end

  def render_empty_state
    tr do
      td(colspan: column_count, class: "px-6 py-8 text-center text-gray-500 dark:text-gray-400") do
        p { "No data available" }
      end
    end
  end

  def render_pagination
    return unless @paginated

    total_pages = (@data.count.to_f / @per_page).ceil

    div(class: "flex items-center justify-between mt-4") do
      div(class: "text-sm text-gray-700 dark:text-gray-400") do
        plain "Showing "
        span(class: "font-medium") { (((@current_page - 1) * @per_page) + 1).to_s }
        plain " to "
        span(class: "font-medium") { [(@current_page * @per_page), @data.count].min.to_s }
        plain " of "
        span(class: "font-medium") { @data.count.to_s }
        plain " results"
      end

      div(class: "flex gap-2") do
        (1..total_pages).each do |page|
          button(
            type: "button",
            class: "px-3 py-1 rounded #{page == @current_page ? "bg-blue-600 text-white" : "bg-gray-200 text-gray-700 hover:bg-gray-300"}"
          ) { page.to_s }
        end
      end
    end
  end

  def row_classes(index)
    classes = []
    classes << "bg-white dark:bg-gray-800" unless @striped && index.even?
    classes << "bg-gray-50 dark:bg-gray-900" if @striped && index.even?
    classes << "hover:bg-gray-100 dark:hover:bg-gray-700" if @hoverable
    classes.join(" ")
  end

  def row_id(row)
    row.is_a?(Hash) ? row[:id] : row.id
  end

  def column_count
    @columns.count + (@selectable ? 1 : 0)
  end

  def paginated_data
    return @data unless @paginated

    start_index = (@current_page - 1) * @per_page
    @data[start_index, @per_page] || []
  end

  # SECURITY: Validate all tenant-scoped records belong to Current.account
  def validate_tenant_isolation!
    return if @data.empty?
    return unless Current.account

    # Check if data is tenant-scoped (has account_id)
    sample = @data.first
    return unless sample.respond_to?(:account_id)

    # Verify all records belong to Current.account
    invalid_records = @data.select do |record|
      record.respond_to?(:account_id) && record.account_id != Current.account.id
    end

    if invalid_records.any?
      raise SecurityError,
        "Tenant isolation violation: TableComponent received #{invalid_records.count} " \
        "records not belonging to Current.account (#{Current.account.id}). " \
        "Record IDs: #{invalid_records.map(&:id).take(5).join(", ")}"
    end
  end
end

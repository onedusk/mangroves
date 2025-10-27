# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TableComponent Performance", type: :component do
  describe "rendering large datasets" do
    context "with 1000 rows" do
      let(:large_dataset) do
        (1..1000).map do |i|
          {
            id: i,
            name: "User #{i}",
            email: "user#{i}@example.com",
            role: %w[Admin Member Viewer].sample,
            created_at: i.days.ago
          }
        end
      end

      let(:columns) { [:id, :name, :email, :role, :created_at] }

      it "renders in under 2 seconds" do
        component = TableComponent.new(data: large_dataset, columns: columns)

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 2.0
      end

      it "handles pagination efficiently" do
        component = TableComponent.new(
          data: large_dataset,
          columns: columns,
          paginated: true,
          per_page: 50
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 0.5 # Much faster with pagination
      end

      it "renders sorted data efficiently" do
        component = TableComponent.new(
          data: large_dataset,
          columns: columns,
          sortable: true
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 2.5
      end

      it "handles selection with large datasets" do
        component = TableComponent.new(
          data: large_dataset,
          columns: columns,
          selectable: true
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 2.5
      end
    end

    context "with 10,000 rows (pagination required)" do
      let(:very_large_dataset) do
        (1..10_000).map do |i|
          {
            id: i,
            name: "User #{i}",
            email: "user#{i}@example.com",
            role: "Member"
          }
        end
      end

      let(:columns) { [:id, :name, :email, :role] }

      it "requires pagination for acceptable performance" do
        component = TableComponent.new(
          data: very_large_dataset,
          columns: columns,
          paginated: true,
          per_page: 100
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 1.0
      end

      it "provides memory-efficient rendering" do
        component = TableComponent.new(
          data: very_large_dataset,
          columns: columns,
          paginated: true,
          per_page: 50
        )

        # Measure memory usage
        before_memory = get_memory_usage
        _rendered = component.call
        after_memory = get_memory_usage

        memory_increase = after_memory - before_memory
        expect(memory_increase).to be < 50 # Less than 50MB increase
      end
    end

    context "with complex column formatters" do
      let(:dataset) do
        (1..500).map do |i|
          {
            id: i,
            name: "User #{i}",
            status: %w[active inactive pending].sample,
            amount: rand(100..10_000)
          }
        end
      end

      let(:columns_with_formatters) do
        [
          :id,
          {key: :name, format: ->(value, _) { value.upcase }},
          {key: :status, format: ->(value, _) { value.capitalize }},
          {key: :amount, format: ->(value, _) { "$#{value.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}" }}
        ]
      end

      it "renders with formatters efficiently" do
        component = TableComponent.new(
          data: dataset,
          columns: columns_with_formatters,
          paginated: true,
          per_page: 50
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 1.0
      end
    end
  end

  describe "pagination performance" do
    context "with 100+ pages" do
      let(:total_items) { 5000 }
      let(:per_page) { 50 }
      let(:total_pages) { (total_items.to_f / per_page).ceil }

      let(:dataset) do
        (1..total_items).map do |i|
          {id: i, name: "Item #{i}", value: rand(1..1000)}
        end
      end

      it "renders pagination controls efficiently" do
        component = PaginationComponent.new(
          total_items: total_items,
          per_page: per_page,
          current_page: 50
        )

        start_time = Time.current
        _rendered = component.call
        end_time = Time.current

        render_time = end_time - start_time
        expect(render_time).to be < 0.1
      end

      it "handles edge cases (first page)" do
        component = PaginationComponent.new(
          total_items: total_items,
          per_page: per_page,
          current_page: 1
        )

        start_time = Time.current
        rendered = component.call
        end_time = Time.current

        expect(end_time - start_time).to be < 0.1
        expect(rendered).to include("1")
      end

      it "handles edge cases (last page)" do
        component = PaginationComponent.new(
          total_items: total_items,
          per_page: per_page,
          current_page: total_pages
        )

        start_time = Time.current
        rendered = component.call
        end_time = Time.current

        expect(end_time - start_time).to be < 0.1
        expect(rendered).to include(total_pages.to_s)
      end

      it "uses smart pagination to avoid rendering all page numbers" do
        component = PaginationComponent.new(
          total_items: total_items,
          per_page: per_page,
          current_page: 50
        )

        rendered = component.call

        # Should use ellipsis rather than rendering 100 page numbers
        page_button_count = rendered.scan("px-3 py-1").length
        expect(page_button_count).to be < 20 # Should show ~10 pages + prev/next + first/last
      end
    end
  end

  def get_memory_usage
    # Get current memory usage in MB
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
  rescue
    0
  end
end

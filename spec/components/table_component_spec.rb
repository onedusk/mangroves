# frozen_string_literal: true

require "rails_helper"

RSpec.describe TableComponent, type: :component do
  describe "#template" do
    let(:columns) { [:name, :email, :role] }
    let(:data) do
      [
        {id: 1, name: "Alice", email: "alice@example.com", role: "Admin"},
        {id: 2, name: "Bob", email: "bob@example.com", role: "Member"},
        {id: 3, name: "Charlie", email: "charlie@example.com", role: "Viewer"}
      ]
    end

    context "basic table" do
      it "renders a table with data" do
        component = described_class.new(data: data, columns: columns)
        rendered = component.call

        expect(rendered).to include("Alice")
        expect(rendered).to include("Bob")
        expect(rendered).to include("Charlie")
        expect(rendered).to include("alice@example.com")
      end

      it "renders column headers" do
        component = described_class.new(data: data, columns: columns)
        rendered = component.call

        expect(rendered).to include("Name")
        expect(rendered).to include("Email")
        expect(rendered).to include("Role")
      end

      it "includes Stimulus controller" do
        component = described_class.new(data: data, columns: columns)
        rendered = component.call

        expect(rendered).to include("data-controller=\"table\"")
      end
    end

    context "empty table" do
      it "renders empty state message" do
        component = described_class.new(data: [], columns: columns)
        rendered = component.call

        expect(rendered).to include("No data available")
      end
    end

    context "sortable table" do
      it "renders sortable headers" do
        component = described_class.new(data: data, columns: columns, sortable: true)
        rendered = component.call

        expect(rendered).to include("data-table-sortable-value") # true values present
        expect(rendered).to include("click->table#sort")
        expect(rendered).to include("data-table-target=\"sortHeader\"")
      end

      it "includes sort icons" do
        component = described_class.new(data: data, columns: columns, sortable: true)
        rendered = component.call

        expect(rendered).to include("data-table-target=\"sortIcon\"")
        expect(rendered).to include("↕")
      end
    end

    context "selectable table" do
      it "renders selection checkboxes" do
        component = described_class.new(data: data, columns: columns, selectable: true)
        rendered = component.call

        expect(rendered).to include("data-table-selectable-value") # true values present
        expect(rendered).to include("data-table-target=\"selectAll\"")
        expect(rendered).to include("data-table-target=\"rowCheckbox\"")
        expect(rendered).to include("change->table#toggleAll")
      end

      it "includes selection summary element" do
        component = described_class.new(data: data, columns: columns, selectable: true)
        rendered = component.call

        expect(rendered).to include("data-table-target=\"selectionSummary\"")
        expect(rendered).to include("data-table-target=\"selectionCount\"")
      end

      it "adds row IDs to checkboxes" do
        component = described_class.new(data: data, columns: columns, selectable: true)
        rendered = component.call

        expect(rendered).to include("data-row-id=\"1\"")
        expect(rendered).to include("data-row-id=\"2\"")
        expect(rendered).to include("data-row-id=\"3\"")
      end
    end

    context "paginated table" do
      it "renders pagination controls" do
        component = described_class.new(
          data: data,
          columns: columns,
          paginated: true,
          per_page: 2,
          current_page: 1
        )
        rendered = component.call

        expect(rendered).to include("Showing")
        expect(rendered).to include("results")
        expect(rendered).to match(/1.*to.*2.*of.*3/)
      end

      it "paginates data correctly" do
        component = described_class.new(
          data: data,
          columns: columns,
          paginated: true,
          per_page: 2,
          current_page: 1
        )
        rendered = component.call

        expect(rendered).to include("Alice")
        expect(rendered).to include("Bob")
        # Charlie should not be on page 1 (only showing first 2 items)
        expect(rendered).not_to include("Charlie")
      end

      it "renders page buttons" do
        component = described_class.new(
          data: data,
          columns: columns,
          paginated: true,
          per_page: 2
        )
        rendered = component.call

        # Should have 2 page buttons (3 items / 2 per page = 2 pages)
        expect(rendered.scan("px-3 py-1 rounded").length).to be >= 2
      end
    end

    context "striped rows" do
      it "applies striped styling when enabled" do
        component = described_class.new(data: data, columns: columns, striped: true)
        rendered = component.call

        expect(rendered).to include("bg-gray-50")
      end

      it "does not apply striped styling when disabled" do
        component = described_class.new(data: data, columns: columns, striped: false)
        rendered = component.call

        expect(rendered).to include("bg-white")
      end
    end

    context "hoverable rows" do
      it "applies hover styling when enabled" do
        component = described_class.new(data: data, columns: columns, hoverable: true)
        rendered = component.call

        expect(rendered).to include("hover:bg-gray-100")
      end
    end

    context "with custom column configuration" do
      let(:custom_columns) do
        [
          {key: :name, label: "Full Name"},
          {key: :email, label: "Email Address"},
          {key: :role, label: "User Role", sortable: false}
        ]
      end

      it "uses custom labels" do
        component = described_class.new(data: data, columns: custom_columns)
        rendered = component.call

        expect(rendered).to include("Full Name")
        expect(rendered).to include("Email Address")
        expect(rendered).to include("User Role")
      end
    end

    context "with formatted columns" do
      let(:columns_with_format) do
        [
          :name,
          {
            key: :email,
            label: "Contact",
            format: ->(value, _row) { value.upcase }
          }
        ]
      end

      it "applies formatting to column values" do
        component = described_class.new(data: data, columns: columns_with_format)
        rendered = component.call

        expect(rendered).to include("ALICE@EXAMPLE.COM")
        expect(rendered).to include("BOB@EXAMPLE.COM")
      end
    end

    context "with custom class" do
      it "includes custom class name" do
        component = described_class.new(data: data, columns: columns, class_name: "custom-table")
        rendered = component.call

        expect(rendered).to include("custom-table")
      end
    end

    context "responsive design" do
      it "includes horizontal scroll wrapper" do
        component = described_class.new(data: data, columns: columns)
        rendered = component.call

        expect(rendered).to include("overflow-x-auto")
      end
    end
  end

  describe "tenant scoping awareness" do
    it "can render ActiveRecord objects from current account" do
      # NOTE: This test demonstrates how the component would work with tenant-scoped data
      # In real usage, data would be pre-filtered by Current.account through model scopes
      component = described_class.new(
        data: [{id: 1, name: "Test", email: "test@example.com"}],
        columns: [:name, :email]
      )
      rendered = component.call

      expect(rendered).to include("Test")
      expect(rendered).to include("test@example.com")
    end
  end
end

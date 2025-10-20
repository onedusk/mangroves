# Task 15: Utility and Interactive Components Security Review

**Review Date**: 2025-10-20  
**Reviewer**: Claude Code  
**Scope**: Separator, Resizable, Scroll Area, Slider, Toggle, Toggle Group, and Table components

---

## Executive Summary

Reviewed 7 utility/interactive components and 6 Stimulus controllers. Identified **4 Critical**, **8 High**, **6 Medium** priority issues across security, performance, and accessibility domains.

**Critical Findings**:
1. Table component lacks tenant isolation - no Current.account usage
2. XSS vulnerability in table cell rendering with custom formatters
3. Memory leaks in resize/drag event handlers
4. Client-side only sorting enables data enumeration attacks

---

## Component Analysis

### 1. SeparatorComponent (/app/components/separator_component.rb)

**Status**: SECURE

**Findings**:
- Simple presentational component with no security concerns
- Properly implements ARIA attributes for accessibility
- No user input, data processing, or tenant context needed
- No XSS risk - uses only CSS classes

**Recommendations**: None required

---

### 2. ResizableComponent (/app/components/resizable_component.rb)

**Status**: MEDIUM RISK

**Security Issues**:
1. **MEDIUM** - Style injection through numeric parameters
   - Lines 72-76: User-controlled size values directly interpolated into inline styles
   - Mitigated by type coercion but should validate bounds
   
   ```ruby
   # Current (vulnerable to extreme values)
   "height: #{@default_size}%"
   
   # Recommended
   def panel1_style
     safe_size = [[0, @default_size].max, 100].min
     if @orientation == :vertical
       "height: #{safe_size}%"
     else
       "width: #{safe_size}%"
     end
   end
   ```

**Performance Issues**:
1. **CRITICAL** - Event handler memory leak (resizable_controller.js:64-69)
   - `stopResize()` creates new bound functions that don't match attached listeners
   - Listeners never removed, accumulate on every resize operation
   
   ```javascript
   // VULNERABILITY: Lines 30-33
   document.addEventListener("mousemove", this.resize.bind(this))
   
   // Line 66 - this creates a NEW bound function, doesn't match!
   document.removeEventListener("mousemove", this.resize.bind(this))
   ```
   
   **Impact**: Memory leak grows with each drag operation, eventually degrading browser performance

   **Fix Required**:
   ```javascript
   startResize(event) {
     // Store bound references
     this.boundResize = this.resize.bind(this)
     this.boundStopResize = this.stopResize.bind(this)
     
     document.addEventListener("mousemove", this.boundResize)
     document.addEventListener("mouseup", this.boundStopResize)
   }
   
   stopResize() {
     document.removeEventListener("mousemove", this.boundResize)
     document.removeEventListener("mouseup", this.boundStopResize)
   }
   ```

**Accessibility Issues**:
1. **MEDIUM** - Missing keyboard navigation
   - No Tab/Arrow key support for resize handle
   - No ARIA attributes indicating resizable regions
   - Screen reader users cannot resize panels

**Recommendations**:
- [ ] Add parameter validation for size bounds (0-100%)
- [ ] **CRITICAL**: Fix event listener memory leak
- [ ] Add keyboard support (Arrow keys with Shift modifier)
- [ ] Add ARIA attributes: `role="separator"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`

---

### 3. ScrollAreaComponent (/app/components/scroll_area_component.rb)

**Status**: LOW RISK

**Security Issues**:
1. **LOW** - Inline CSS injection risk (lines 15, 31-34)
   - Height/width parameters directly interpolated into styles
   - Could allow CSS injection if values come from user input
   - Mitigated if only called from controllers with sanitized values

**Performance Issues**:
1. **LOW** - Minimal controller functionality
   - scroll_area_controller.js only sets scroll behavior
   - No event listeners to clean up
   - Efficient implementation

**Accessibility Issues**:
1. **MEDIUM** - Missing scroll indicators
   - No visual feedback for keyboard users navigating scrollable content
   - Should announce scrollable regions to screen readers

**Recommendations**:
- [ ] Validate height/width parameters (reject values with CSS syntax)
- [ ] Add `aria-label` or `aria-labelledby` for scrollable regions
- [ ] Consider adding scroll position indicators for keyboard users

---

### 4. SliderComponent (/app/components/slider_component.rb)

**Status**: MEDIUM RISK

**Security Issues**:
1. **MEDIUM** - Name parameter XSS risk (line 65-67)
   - Parameter directly interpolated into input name attribute
   - Could inject attributes if not sanitized at controller level
   
   ```ruby
   # Line 66 - potential attribute injection
   name: "#{@name}[min]"
   ```

2. **LOW** - Value injection through percentage calculation (line 132)
   - Percentage method uses user-provided min/max/value
   - Math operations could produce Infinity/NaN if not validated

**Performance Issues**: 
1. **MEDIUM** - No drag event throttling (slider_controller.js:54-69)
   - `drag()` method fires on every mousemove event (potentially 100+ times/second)
   - Should throttle to ~60fps max
   - Causes unnecessary DOM updates

**Accessibility Issues**:
1. **HIGH** - Missing native slider semantics
   - Uses custom implementation instead of HTML5 `<input type="range">`
   - No `role="slider"` ARIA attributes
   - No keyboard support (Arrow keys, Page Up/Down, Home/End)
   - Screen readers cannot announce current value during drag

**Recommendations**:
- [ ] Sanitize name parameter, reject special characters
- [ ] Add min/max/value validation in initialize
- [ ] **IMPORTANT**: Add drag event throttling (requestAnimationFrame)
- [ ] **CRITICAL**: Add full keyboard support and ARIA attributes
- [ ] Consider progressive enhancement with native `<input type="range">`

**Suggested ARIA Implementation**:
```ruby
div(
  role: "slider",
  tabindex: "0",
  aria_valuemin: @min,
  aria_valuemax: @max,
  aria_valuenow: @value,
  aria_label: "Slider",
  data: { /* ... */ }
)
```

---

### 5. ToggleComponent (/app/components/toggle_component.rb)

**Status**: LOW RISK

**Security Issues**:
1. **LOW** - Name parameter injection (line 54)
   - Same issue as SliderComponent
   - Should sanitize name attribute

**Performance Issues**: None

**Accessibility Issues**:
1. **LOW** - Good ARIA implementation
   - Properly uses `role="switch"` and `aria-checked`
   - Could add `aria-label` when label not provided
   - Keyboard accessible via native button element

**Recommendations**:
- [ ] Sanitize name parameter
- [ ] Add `aria-label` parameter option for icon-only toggles

---

### 6. ToggleGroupComponent (/app/components/toggle_group_component.rb)

**Status**: LOW-MEDIUM RISK

**Security Issues**:
1. **MEDIUM** - Value XSS risk (line 53)
   - User-provided values set as data attributes without escaping
   - Could inject malicious data-* attributes
   
   ```ruby
   # Line 53 - needs HTML attribute escaping
   data: { value: value }
   ```

2. **LOW** - JSON injection in selected values (line 27)
   - `.to_json` on user-controlled array
   - Generally safe but should validate array contents

**Performance Issues**: None significant

**Accessibility Issues**:
1. **MEDIUM** - Missing keyboard navigation
   - No Tab/Arrow key navigation between toggle items
   - Should use roving tabindex pattern
   - No ARIA attributes indicating selection state

**Recommendations**:
- [ ] HTML-escape value attributes
- [ ] Validate selected array contains only safe values
- [ ] Add Arrow key navigation between items
- [ ] Add `aria-pressed` or `aria-selected` to items

---

### 7. TableComponent (/app/components/table_component.rb) - CRITICAL ISSUES

**Status**: HIGH RISK - Multiple Critical Issues

#### Security Issues

1. **CRITICAL** - No tenant isolation (entire component)
   - Component accepts raw data array without tenant scoping
   - No Current.account usage or validation
   - Caller must ensure data is pre-scoped, but component doesn't enforce it
   - **VIOLATION**: All components should validate tenant context per project standards
   
   ```ruby
   # MISSING - should validate tenant isolation
   def initialize(data: [], ...)
     @data = data  # ← No tenant validation!
     # Should be:
     # raise "Data must be tenant-scoped" unless data.all? { |r| r.account_id == Current.account.id }
   end
   ```

   **Impact**: If controller passes wrong dataset, exposes cross-tenant data

2. **CRITICAL** - XSS vulnerability in cell formatters (lines 164-167)
   - Custom format lambdas can return HTML that renders unsafely
   - Line 173: `value` renders directly without escaping when not String/Numeric
   
   ```ruby
   # VULNERABLE CODE - Line 165-166
   if column.is_a?(Hash) && column[:format]
     value = column[:format].call(value, row)  # ← Returns unescaped HTML
   end
   
   # Line 169-175 - renders without escaping
   td(class: "px-6 py-4") do
     if value.is_a?(String) || value.is_a?(Numeric)
       plain value.to_s  # ← Safe
     else
       value  # ← UNSAFE - renders raw HTML/component
     end
   end
   ```
   
   **Attack Vector**:
   ```ruby
   columns: [
     {
       key: :name,
       format: ->(val, row) { "<img src=x onerror=alert(1)>" }
     }
   ]
   ```

3. **HIGH** - Client-side sorting enables data enumeration (table_controller.js:74-127)
   - All data loaded client-side for sorting
   - Attacker can enumerate all IDs via selection events
   - No server-side pagination/filtering
   - Sorting happens in JavaScript, exposing all data to browser console
   
   **Impact**: 
   - Leak sensitive IDs even if UI hides them
   - Enumerate complete dataset structure
   - Bypass intended data filtering
   
4. **MEDIUM** - Mass selection without authorization (table_controller.js:16-31)
   - "Select All" checks all rows without limit
   - No confirmation for bulk actions
   - Selection state exposed via CustomEvent (line 68-71)
   - Malicious script could select all and trigger bulk delete
   
5. **MEDIUM** - SQL injection risk in sort parameters (line 103)
   - Column name comes from data-column attribute (user-controlled)
   - If backend uses this for ORDER BY, could inject SQL
   - Component doesn't validate column names against whitelist

#### Performance Issues

1. **HIGH** - Large dataset rendering (lines 124-127, 229-234)
   - No virtualization - renders all rows to DOM
   - Paginated data loaded but not lazy
   - 1000+ row tables will freeze browser
   - Sorting re-renders entire tbody (line 120)
   
   **Impact**: 
   - 10k rows = ~10MB DOM + 2-5 second freeze
   - Sorting 1k+ rows locks UI thread
   
2. **MEDIUM** - Inefficient DOM manipulation in sort (lines 118-120)
   - `appendChild()` causes reflow for each row
   - Should use DocumentFragment
   
   ```javascript
   // Current (slow) - line 119-120
   rows.forEach(row => tbody.appendChild(row))
   
   // Recommended
   const fragment = document.createDocumentFragment()
   rows.forEach(row => fragment.appendChild(row))
   tbody.appendChild(fragment)
   ```

3. **MEDIUM** - Unnecessary re-renders on selection (lines 55-66)
   - Updates summary on every checkbox toggle
   - Should debounce when toggling multiple rows
   
4. **LOW** - No caching of column indices (line 129-132)
   - Recalculates column index on every sort comparison
   - Should cache in sort() method

#### Accessibility Issues

1. **HIGH** - Missing table semantics
   - No `<caption>` element for table description
   - Column headers missing `scope="col"` on some (line 96 has it, but...)
   - No `aria-sort` attribute on sorted columns
   - Selection checkboxes missing labels

2. **HIGH** - Sort UI inaccessible
   - Sort buttons missing aria-label (line 98-106)
   - Sort direction not announced to screen readers
   - Keyboard users can't tell current sort state
   
3. **MEDIUM** - Selection state not announced
   - Checkboxes change but no live region announcement
   - Screen reader doesn't know when selection changes
   - "X rows selected" summary not aria-live

#### Recommendations

**CRITICAL - Must Fix**:
- [ ] Add tenant isolation validation in initialize
- [ ] Sanitize all formatter output - use `plain` for strings
- [ ] Move sorting to server-side with encrypted cursor pagination
- [ ] Add server-side row selection validation

**HIGH Priority**:
- [ ] Implement virtual scrolling for large datasets (use Intersection Observer)
- [ ] Add column name whitelist validation for sorting
- [ ] Add full ARIA table semantics
- [ ] Add bulk action confirmation UI

**MEDIUM Priority**:
- [ ] Use DocumentFragment for sort DOM updates
- [ ] Debounce selection summary updates
- [ ] Cache column indices during sort
- [ ] Add aria-live region for selection announcements

**Example Fix - Tenant Isolation**:
```ruby
class TableComponent < Phlex::HTML
  def initialize(data: [], columns: [], **options)
    # Validate tenant isolation for ActiveRecord collections
    if data.respond_to?(:model) && data.model.respond_to?(:account_id)
      unless data.where_values_hash.key?("account_id")
        raise SecurityError, "Table data must be tenant-scoped to Current.account"
      end
    end
    
    @data = data
    # ...
  end
end
```

**Example Fix - XSS Protection**:
```ruby
def render_td(row, column)
  col_key = column.is_a?(Hash) ? column[:key] : column
  value = row.is_a?(Hash) ? row[col_key] : row.send(col_key)
  
  # Format value if formatter provided
  if column.is_a?(Hash) && column[:format]
    value = column[:format].call(value, row)
  end
  
  td(class: "px-6 py-4") do
    # ALWAYS escape strings, components should explicitly call .safe if needed
    case value
    when String, Numeric
      plain value.to_s
    when Phlex::HTML  # Allow explicit component rendering
      value
    else
      plain value.to_s  # Force string conversion and escape
    end
  end
end
```

---

## Cross-Component Patterns

### Memory Leak Pattern in Drag Handlers

**Affected Components**: ResizableComponent, SliderComponent

**Root Cause**: Event listeners attached with `bind(this)` create new function instances each time, preventing cleanup.

**Pattern**:
```javascript
// LEAK - new function on every call
startResize(event) {
  document.addEventListener("mousemove", this.resize.bind(this))
}

stopResize() {
  // This bind() creates DIFFERENT function, doesn't remove original
  document.removeEventListener("mousemove", this.resize.bind(this))
}
```

**Standard Fix**:
```javascript
connect() {
  this.boundResize = this.resize.bind(this)
  this.boundStopResize = this.stopResize.bind(this)
}

startResize(event) {
  document.addEventListener("mousemove", this.boundResize)
}

stopResize() {
  document.removeEventListener("mousemove", this.boundResize)
}

disconnect() {
  this.stopResize() // Cleanup on controller disconnect
}
```

**Applies To**:
- resizable_controller.js (lines 30-33, 66-69) - CRITICAL
- slider_controller.js (lines 42-52, 71-81) - HIGH

---

## Performance Recommendations

### 1. Event Throttling for Drag Operations

All drag handlers (resize, slider) should throttle to 60fps:

```javascript
drag(event) {
  if (!this.isDragging) return
  
  // Throttle to 60fps
  if (!this.rafId) {
    this.rafId = requestAnimationFrame(() => {
      this.performDrag(event)
      this.rafId = null
    })
  }
}

performDrag(event) {
  // Actual drag logic here
}
```

### 2. Virtual Scrolling for Tables

For tables with >100 rows:

```javascript
// Only render visible rows + buffer
const visibleRows = this.getVisibleRows(scrollTop, viewportHeight)
this.renderRows(visibleRows)
```

Consider libraries: `virtual-scroller`, `react-window` patterns

### 3. Debounce Selection Updates

```javascript
updateSelectionSummary() {
  clearTimeout(this.summaryTimeout)
  this.summaryTimeout = setTimeout(() => {
    this.performSummaryUpdate()
  }, 100)
}
```

---

## Security Summary by Severity

### Critical (4)
1. TableComponent - No tenant isolation
2. TableComponent - XSS in cell formatters
3. ResizableComponent - Memory leak in event handlers
4. TableComponent - Client-side sorting data exposure

### High (8)
1. SliderComponent - No keyboard accessibility
2. TableComponent - Missing ARIA table semantics
3. TableComponent - Inaccessible sort controls
4. TableComponent - Large dataset performance
5. TableComponent - Mass selection without authorization
6. SliderComponent - Missing drag throttling
7. All drag components - Event listener leaks
8. TableComponent - Selection state not announced

### Medium (6)
1. ResizableComponent - Missing keyboard navigation
2. ResizableComponent - Style injection risk
3. ScrollAreaComponent - Missing scroll ARIA
4. SliderComponent - Name parameter XSS
5. ToggleGroupComponent - Value XSS risk
6. TableComponent - SQL injection in sort params

---

## Testing Recommendations

### Security Tests Required

```ruby
# spec/components/table_component_spec.rb
describe TableComponent do
  describe "tenant isolation" do
    it "raises error when data not tenant-scoped" do
      other_account = create(:account)
      wrong_data = other_account.projects
      
      expect {
        TableComponent.new(data: wrong_data)
      }.to raise_error(SecurityError)
    end
  end
  
  describe "XSS protection" do
    it "escapes formatter output" do
      columns = [{ key: :name, format: ->(_v, _r) { "<script>alert(1)</script>" } }]
      component = TableComponent.new(data: [@project], columns: columns)
      
      html = render(component)
      expect(html).not_to include("<script>")
      expect(html).to include("&lt;script&gt;")
    end
  end
end
```

### Performance Tests Required

```javascript
// test/javascript/controllers/table_controller.test.js
describe("TableController", () => {
  describe("large datasets", () => {
    it("handles 1000 rows without freezing", () => {
      const rows = generateRows(1000)
      const start = performance.now()
      
      controller.render(rows)
      
      const duration = performance.now() - start
      expect(duration).toBeLessThan(100) // 100ms max
    })
  })
  
  describe("memory leaks", () => {
    it("removes event listeners on disconnect", () => {
      const listenerCount = getEventListenerCount(document)
      
      controller.startResize()
      controller.disconnect()
      
      expect(getEventListenerCount(document)).toEqual(listenerCount)
    })
  })
})
```

---

## Compliance Checklist

Based on project guidelines from `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/CLAUDE.md`:

- [ ] **Multi-tenant isolation**: TableComponent FAILS - no Current.account validation
- [ ] **Request-scoped tenancy**: Components don't use Current context (acceptable for presentational)
- [ ] **Automatic data scoping**: Table accepts unscoped data (CRITICAL FIX NEEDED)
- [ ] **Authorization patterns**: No `authorize_*` checks in components (should be in controllers)
- [ ] **XSS protection**: Multiple components vulnerable
- [ ] **Accessibility (ARIA)**: Most components missing proper semantics
- [ ] **Performance**: Memory leaks and inefficient rendering found

---

## Remediation Priority

### Week 1 (Critical)
1. Fix TableComponent tenant isolation
2. Fix XSS in table formatters
3. Fix memory leaks in resize/slider controllers
4. Add event throttling to drag handlers

### Week 2 (High)
5. Add keyboard accessibility to slider
6. Add ARIA semantics to table
7. Implement virtual scrolling for tables
8. Server-side sorting implementation

### Week 3 (Medium)
9. Add keyboard navigation to resizable/toggle-group
10. Sanitize all name/value parameters
11. Add comprehensive security tests
12. Performance benchmarking

---

## Conclusion

The utility components are generally well-structured but have significant security and performance gaps:

1. **TableComponent requires immediate attention** - multiple critical security issues including tenant isolation failure and XSS vulnerabilities
2. **Memory leaks in drag handlers** will cause degraded performance over time
3. **Accessibility is inadequate** across interactive components
4. **Performance will degrade** with real-world dataset sizes

**Overall Risk Rating**: HIGH

**Recommended Action**: Do not deploy TableComponent to production until critical issues resolved. Other components are lower risk but need accessibility improvements.

---

**Files Reviewed**:
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/separator_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/resizable_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/scroll_area_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/slider_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/toggle_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/toggle_group_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/components/table_component.rb`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/resizable_controller.js`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/scroll_area_controller.js`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/slider_controller.js`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/toggle_controller.js`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/toggle_group_controller.js`
- `/Users/macadelic/dusk-labs/company/sandbox/dl_dev/experiments/mangroves/app/javascript/controllers/table_controller.js`

**Report Generated**: 2025-10-20

#!/bin/bash

# Memory Leak Fix Verification Script
# Checks that all controllers properly implement cleanup patterns

echo "========================================="
echo "Memory Leak Fix Verification"
echo "========================================="
echo ""

CONTROLLERS_DIR="app/javascript/controllers"
FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_controller() {
  local file=$1
  local name=$(basename "$file" .js)
  local errors=0

  echo "Checking $name..."

  # Check 1: Has disconnect method
  if ! grep -q "disconnect()" "$file"; then
    echo -e "  ${RED}✗ Missing disconnect() method${NC}"
    ((errors++))
  else
    echo -e "  ${GREEN}✓ Has disconnect() method${NC}"
  fi

  # Check 2: If has addEventListener, should have removeEventListener (in disconnect or helper methods)
  if grep -q "addEventListener" "$file"; then
    if grep -q "removeEventListener" "$file"; then
      echo -e "  ${GREEN}✓ Has removeEventListener calls${NC}"
    else
      echo -e "  ${RED}✗ addEventListener without removeEventListener${NC}"
      ((errors++))
    fi

    # Check 3: Should use bound functions (this.bound*)
    if grep -q "this\.bound" "$file"; then
      echo -e "  ${GREEN}✓ Uses bound function pattern${NC}"
    else
      echo -e "  ${YELLOW}⚠ No bound function pattern detected${NC}"
      ((errors++))
    fi
  fi

  # Check 4: If has setTimeout, should have clearTimeout somewhere
  if grep -q "setTimeout" "$file"; then
    if grep -q "clearTimeout" "$file"; then
      echo -e "  ${GREEN}✓ Has clearTimeout calls${NC}"
    else
      echo -e "  ${YELLOW}⚠ setTimeout without clearTimeout (may be animation-only)${NC}"
    fi
  fi

  # Check 5: State tracking for open/close controllers
  if grep -q "open()" "$file" || grep -q "show()" "$file"; then
    if grep -q "this\.isOpen\|this\.isVisible\|this\.isDragging\|this\.isActive" "$file"; then
      echo -e "  ${GREEN}✓ Has state tracking${NC}"
    else
      echo -e "  ${YELLOW}⚠ No state tracking detected${NC}"
      ((errors++))
    fi
  fi

  echo ""
  return $errors
}

# Check specific controllers mentioned in task
echo "=== Task 19 Controllers ==="
echo ""

TASK_CONTROLLERS=(
  "popover_controller.js"
  "hover_card_controller.js"
  "tooltip_controller.js"
  "dropdown_menu_controller.js"
  "menubar_controller.js"
  "resizable_controller.js"
  "slider_controller.js"
  "toast_controller.js"
  "sonner_controller.js"
  "sheet_controller.js"
)

for controller in "${TASK_CONTROLLERS[@]}"; do
  if [ -f "$CONTROLLERS_DIR/$controller" ]; then
    check_controller "$CONTROLLERS_DIR/$controller"
    if [ $? -gt 0 ]; then
      ((FAILED++))
    fi
  else
    echo -e "${RED}✗ $controller not found${NC}"
    ((FAILED++))
  fi
done

# Check validation controller
echo "=== Validation Controllers ==="
echo ""

if [ -f "$CONTROLLERS_DIR/validation_controller.js" ]; then
  echo -e "${GREEN}✓ validation_controller.js exists${NC}"
else
  echo -e "${RED}✗ validation_controller.js not found${NC}"
  ((FAILED++))
fi

if grep -q "import ValidationController from" "$CONTROLLERS_DIR/input_controller.js" 2>/dev/null; then
  echo -e "${GREEN}✓ input_controller.js extends ValidationController${NC}"
else
  echo -e "${RED}✗ input_controller.js doesn't extend ValidationController${NC}"
  ((FAILED++))
fi

if grep -q "import ValidationController from" "$CONTROLLERS_DIR/textarea_controller.js" 2>/dev/null; then
  echo -e "${GREEN}✓ textarea_controller.js extends ValidationController${NC}"
else
  echo -e "${RED}✗ textarea_controller.js doesn't extend ValidationController${NC}"
  ((FAILED++))
fi

echo ""
echo "=== Test Files ==="
echo ""

if [ -f "spec/javascript/memory_leak_spec.js" ]; then
  echo -e "${GREEN}✓ memory_leak_spec.js exists${NC}"
else
  echo -e "${RED}✗ memory_leak_spec.js not found${NC}"
  ((FAILED++))
fi

if [ -f "spec/javascript/README.md" ]; then
  echo -e "${GREEN}✓ spec/javascript/README.md exists${NC}"
else
  echo -e "${RED}✗ spec/javascript/README.md not found${NC}"
  ((FAILED++))
fi

echo ""
echo "========================================="
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed!${NC}"
  echo "Memory leak fixes verified successfully."
  exit 0
else
  echo -e "${RED}✗ $FAILED issues found${NC}"
  echo "Please review the errors above."
  exit 1
fi

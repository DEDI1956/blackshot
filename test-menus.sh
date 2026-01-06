#!/usr/bin/env bash
# ============================================================================
# Test script untuk memverifikasi menu structure
# ============================================================================

echo "========================================="
echo "VPN Menu Scripts - Test Suite"
echo "========================================="
echo

# Warna untuk output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

test_file() {
  local file="$1"
  local name="$2"
  
  if [[ -f "$file" ]]; then
    if bash -n "$file" 2>/dev/null; then
      echo -e "${GREEN}✓${NC} $name - Syntax OK"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} $name - Syntax ERROR"
      ((FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} $name - File not found: $file"
    ((FAILED++))
  fi
}

test_executable() {
  local file="$1"
  local name="$2"
  
  if [[ -x "$file" ]]; then
    echo -e "${GREEN}✓${NC} $name - Executable"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} $name - Not executable"
    ((FAILED++))
  fi
}

echo "=== Testing File Existence & Syntax ==="
echo

test_file "/home/engine/project/usr/bin/vpn-lib.sh" "vpn-lib.sh"
test_file "/home/engine/project/usr/bin/menu" "menu"
test_file "/home/engine/project/usr/bin/ssh-menu" "ssh-menu"
test_file "/home/engine/project/usr/bin/vmess-menu" "vmess-menu"
test_file "/home/engine/project/usr/bin/vless-menu" "vless-menu"
test_file "/home/engine/project/usr/bin/trojan-menu" "trojan-menu"

echo
echo "=== Testing Executable Permission ==="
echo

test_executable "/home/engine/project/usr/bin/vpn-lib.sh" "vpn-lib.sh"
test_executable "/home/engine/project/usr/bin/menu" "menu"
test_executable "/home/engine/project/usr/bin/ssh-menu" "ssh-menu"
test_executable "/home/engine/project/usr/bin/vmess-menu" "vmess-menu"
test_executable "/home/engine/project/usr/bin/vless-menu" "vless-menu"
test_executable "/home/engine/project/usr/bin/trojan-menu" "trojan-menu"

echo
echo "=== Testing Library Functions ==="
echo

# Test sourcing library
if bash -c 'source /home/engine/project/usr/bin/vpn-lib.sh 2>/dev/null && declare -F cls >/dev/null' 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Library sourcing works"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Library sourcing failed"
  ((FAILED++))
fi

# Test key functions exist
for func in cls pause fmt_onoff svc_is_active svc_restart_if_exists require_root print_header get_os render_dashboard; do
  if bash -c "source /home/engine/project/usr/bin/vpn-lib.sh 2>/dev/null && declare -F $func >/dev/null" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Function exists: $func"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Function missing: $func"
    ((FAILED++))
  fi
done

echo
echo "=== Testing Installer Scripts ==="
echo

test_file "/home/engine/project/install-menus.sh" "install-menus.sh"
test_executable "/home/engine/project/install-menus.sh" "install-menus.sh"
test_file "/home/engine/project/uninstall-menus.sh" "uninstall-menus.sh"
test_executable "/home/engine/project/uninstall-menus.sh" "uninstall-menus.sh"

echo
echo "========================================="
echo "Test Results:"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "========================================="

if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
fi

#!/usr/bin/env bash
# Test script for backup/restore functionality

echo "Testing Backup/Restore Functionality"
echo "====================================="
echo

# Test 1: Check if backup directory exists
if [[ -d "/root/backup" ]]; then
  echo "✅ Backup directory exists: /root/backup"
else
  echo "❌ Backup directory does not exist"
  mkdir -p /root/backup
  echo "✅ Created backup directory: /root/backup"
fi

# Test 2: Check if backup function exists in menu
if grep -q "do_backup()" /home/engine/project/usr/bin/menu; then
  echo "✅ Backup function found in menu"
else
  echo "❌ Backup function not found in menu"
fi

# Test 3: Check if restore function exists in menu
if grep -q "do_restore()" /home/engine/project/usr/bin/menu; then
  echo "✅ Restore function found in menu"
else
  echo "❌ Restore function not found in menu"
fi

# Test 4: Check if validations exist in ssh-menu
if grep -q "Jangan buat akun jika nama sudah ada" /home/engine/project/usr/bin/ssh-menu; then
  echo "✅ Duplicate account validation found"
else
  echo "❌ Duplicate account validation not found"
fi

if grep -q "Jangan delete akun root" /home/engine/project/usr/bin/ssh-menu; then
  echo "✅ Root deletion prevention found"
else
  echo "❌ Root deletion prevention not found"
fi

if grep -q "Konfirmasi sebelum delete" /home/engine/project/usr/bin/ssh-menu; then
  echo "✅ Delete confirmation found"
else
  echo "❌ Delete confirmation not found"
fi

# Test 5: Check if Ctrl+C trap exists
if grep -q "trap.*INT" /home/engine/project/usr/bin/vpn-lib.sh; then
  echo "✅ Ctrl+C trap found in library"
else
  echo "❌ Ctrl+C trap not found in library"
fi

# Test 6: Check if Telegram bot script exists
if [[ -f "/home/engine/project/usr/bin/telegram-bot.sh" ]]; then
  echo "✅ Telegram bot script exists"
  if [[ -x "/home/engine/project/usr/bin/telegram-bot.sh" ]]; then
    echo "✅ Telegram bot script is executable"
  else
    echo "❌ Telegram bot script is not executable"
  fi
else
  echo "❌ Telegram bot script not found"
fi

# Test 7: Check backup format
if grep -q "/root/backup/vpn-backup" /home/engine/project/usr/bin/menu; then
  echo "✅ Backup format correct: /root/backup/vpn-backup-TIMESTAMP.tar.gz"
else
  echo "❌ Backup format not correct"
fi

# Test 8: Check restore validations
if grep -q "Jangan restore jika akan menimpa akun root" /home/engine/project/usr/bin/menu; then
  echo "✅ Restore root prevention found"
else
  echo "❌ Restore root prevention not found"
fi

if grep -q "Cek duplicate" /home/engine/project/usr/bin/menu; then
  echo "✅ Restore duplicate prevention found"
else
  echo "❌ Restore duplicate prevention not found"
fi

echo
echo "Test Summary:"
echo "============="
echo "All basic tests completed. Check output above for any failures."
echo
echo "Manual testing recommended:"
echo "1. Run: sudo bash install-menus.sh"
echo "2. Run: sudo menu"
echo "3. Test backup/restore functionality"
echo "4. Test SSH account management with validations"

#!/usr/bin/env bash
# ============================================================================
# Installer untuk VPN Menu Scripts
# Script ini akan menginstall semua menu ke /usr/bin
# ============================================================================

set -e

# Cek root
if [[ "${EUID}" -ne 0 ]]; then
  echo "[ERROR] Script ini harus dijalankan sebagai root."
  echo "Jalankan: sudo bash $0"
  exit 1
fi

echo "========================================="
echo "VPN Menu Scripts Installer"
echo "========================================="
echo

# Direktori source
SRC_DIR="$(cd "$(dirname "$0")/usr/bin" && pwd)"

# Daftar file yang akan diinstall
FILES=(
  "vpn-lib.sh"
  "menu"
  "ssh-menu"
  "vmess-menu"
  "vless-menu"
  "trojan-menu"
)

echo "[INFO] Menginstall menu scripts ke /usr/bin..."
echo

# Copy dan set permission
for file in "${FILES[@]}"; do
  if [[ -f "$SRC_DIR/$file" ]]; then
    echo "  → Installing $file"
    cp "$SRC_DIR/$file" "/usr/bin/$file"
    chmod +x "/usr/bin/$file"
  else
    echo "  ✗ File tidak ditemukan: $SRC_DIR/$file"
    exit 1
  fi
done

echo
echo "========================================="
echo "[OK] Instalasi selesai!"
echo "========================================="
echo
echo "Menu yang tersedia:"
echo "  - menu           : Menu utama"
echo "  - ssh-menu       : Menu SSH"
echo "  - vmess-menu     : Menu VMESS"
echo "  - vless-menu     : Menu VLESS"
echo "  - trojan-menu    : Menu TROJAN"
echo
echo "Jalankan dengan: menu"
echo

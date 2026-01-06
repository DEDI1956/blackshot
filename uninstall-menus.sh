#!/usr/bin/env bash
# ============================================================================
# Uninstaller untuk VPN Menu Scripts
# Script ini akan menghapus semua menu dari /usr/bin
# ============================================================================

set -e

# Cek root
if [[ "${EUID}" -ne 0 ]]; then
  echo "[ERROR] Script ini harus dijalankan sebagai root."
  echo "Jalankan: sudo bash $0"
  exit 1
fi

echo "========================================="
echo "VPN Menu Scripts Uninstaller"
echo "========================================="
echo

# Daftar file yang akan dihapus
FILES=(
  "/usr/bin/vpn-lib.sh"
  "/usr/bin/menu"
  "/usr/bin/ssh-menu"
  "/usr/bin/vmess-menu"
  "/usr/bin/vless-menu"
  "/usr/bin/trojan-menu"
)

echo "[WARN] File-file berikut akan dihapus:"
for file in "${FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo "  - $file"
  fi
done

echo
read -r -p "Lanjutkan? (y/N): " yn

if [[ "${yn,,}" != "y" ]]; then
  echo "Dibatalkan."
  exit 0
fi

echo
echo "[INFO] Menghapus menu scripts..."

# Hapus file
for file in "${FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo "  → Removing $file"
    rm -f "$file"
  fi
done

echo
echo "========================================="
echo "[OK] Uninstall selesai!"
echo "========================================="
echo

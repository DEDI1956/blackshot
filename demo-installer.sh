#!/usr/bin/env bash
# ============================================================================
# VPN INSTALLER DEMO
# Demonstration of the one-command VPN installer
# ============================================================================

set -euo pipefail

# Colors
if command -v tput >/dev/null 2>&1; then
  C_RESET="$(tput sgr0)"
  C_BOLD="$(tput bold)"
  C_DIM="$(tput dim)"
  C_RED="$(tput setaf 1)"
  C_GREEN="$(tput setaf 2)"
  C_YELLOW="$(tput setaf 3)"
  C_BLUE="$(tput setaf 4)"
  C_MAGENTA="$(tput setaf 5)"
  C_CYAN="$(tput setaf 6)"
  C_WHITE="$(tput setaf 7)"
else
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE=''
fi

clear

cat <<'EOF'
 ╔══════════════════════════════════════════════════════════════╗
 ║                                                              ║
 ║           🔥 VPN ALL-IN-ONE INSTALLER DEMO 🔥                ║
 ║                                                              ║
 ║              One Command • Full Setup • Easy                 ║
 ║                                                              ║
 ╚══════════════════════════════════════════════════════════════╝
EOF

echo
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                       FITUR UNGGULAN                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║ 🚀 One-Command Install         ✓ Auto SSL Setup             ║"
echo "║ 🔒 Domain-Based Setup           ✓ Auto SSL Renewal          ║"
echo "║ 🎛️  TUI Management Panel       ✓ Backup & Restore          ║"
echo "║ 📊 Real-time Monitoring        ✓ Telegram Bot              ║"
echo "║ 🔧 Multi-Protocol Support       ✓ Speedtest Tools           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

echo "${C_YELLOW}📋 CARA PENGGUNAAN:${C_RESET}"
echo
echo "${C_BOLD}1. Download & Jalankan Installer:${C_RESET}"
echo "   ${C_GREEN}curl -fsSL https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-vpn.sh | sudo bash${C_RESET}"
echo
echo "${C_BOLD}2. Atau download manual:${C_RESET}"
echo "   ${C_GREEN}wget -O install-vpn.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-vpn.sh${C_RESET}"
echo "   ${C_GREEN}sudo bash install-vpn.sh${C_RESET}"
echo

echo "${C_BOLD}3. Ikuti langkah-langkah:${C_RESET}"
echo "   ✓ Installer akan meminta domain Anda"
echo "   ✓ Validasi domain dan DNS"
echo "   ✓ Install dependency secara otomatis"
echo "   ✓ Setup SSL certificate"
echo "   ✓ Konfigurasi semua layanan"
echo "   ✓ Tampilan hasil instalasi"
echo

echo "${C_BOLD}4. Mulai menggunakan:${C_RESET}"
echo "   ${C_GREEN}menu${C_RESET}              - Buka menu utama"
echo "   ${C_GREEN}vpn-panel${C_RESET}       - Buka panel lengkap"
echo "   ${C_GREEN}menu ssh${C_RESET}        - Kelola SSH users"
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "${C_BOLD}${C_YELLOW}🎯 KEUNGGULAN INSTALLER:${C_RESET}"
echo
echo "${C_GREEN}✨ Tampilan Mewah & Modern${C_RESET}"
echo "   • ASCII art yang menarik"
echo "   • Progress bar dengan animasi"
echo "   • Color-coded output"
echo "   • User-friendly interface"
echo
echo "${C_GREEN}🔧 Otomatisasi Penuh${C_RESET}"
echo "   • Auto-detect OS compatibility"
echo "   • Install semua dependency"
echo "   • Setup firewall & security"
echo "   • Configure SSL certificate"
echo
echo "${C_GREEN}📊 Monitoring & Management${C_RESET}"
echo "   • Real-time dashboard"
echo "   • Service status monitoring"
echo "   • Resource usage tracking"
echo "   • Log management"
echo
echo "${C_GREEN}🛡️  Keamanan & Backup${C_RESET}"
echo "   • Auto backup configuration"
echo "   • Fail2ban protection"
echo "   • UFW firewall setup"
echo "   • SSL certificate management"
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "${C_BOLD}${C_MAGENTA}🚀 QUICK START GUIDE:${C_RESET}"
echo
echo "${C_YELLOW}Step 1:${C_RESET} ${C_WHITE}Pastikan VPS Anda menggunakan Ubuntu 20.04/22.04${C_RESET}"
echo
echo "${C_YELLOW}Step 2:${C_RESET} ${C_WHITE}Siapkan domain yang menunjuk ke IP VPS${C_RESET}"
echo
echo "${C_YELLOW}Step 3:${C_RESET} ${C_WHITE}Jalankan installer:${C_RESET}"
echo
echo "   ${C_CYAN}# Option 1: Direct download & install${C_RESET}"
echo "   ${C_GREEN}curl -fsSL https://your-domain.com/install-vpn.sh | sudo bash${C_RESET}"
echo
echo "   ${C_CYAN}# Option 2: Manual download${C_RESET}"
echo "   ${C_GREEN}wget -O install.sh https://your-domain.com/install-vpn.sh${C_RESET}"
echo "   ${C_GREEN}sudo bash install.sh${C_RESET}"
echo
echo "${C_YELLOW}Step 4:${C_RESET} ${C_WHITE}Ikuti prompts installer (domain, konfirmasi, dll)${C_RESET}"
echo
echo "${C_YELLOW}Step 5:${C_WHITE} Mulai menggunakan dengan perintah ${C_GREEN}menu${C_RESET}"
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "${C_BOLD}${C_RED}⚠️  PERSYARATAN:${C_RESET}"
echo "   • ${C_YELLOW}Root access${C_RESET} (sudo)"
echo "   • ${C_YELLOW}Ubuntu 20.04/22.04${C_RESET}"
echo "   • ${C_YELLOW}Koneksi internet${C_RESET}"
echo "   • ${C_YELLOW}Domain yang menunjuk ke VPS${C_RESET}"
echo "   • ${C_YELLOW}Port 80, 443, 22 terbuka${C_RESET}"
echo

echo "${C_BOLD}${C_GREEN}💡 TIPS:${C_RESET}"
echo "   • Gunakan ${C_CYAN}tmux${C_RESET} jika koneksi tidak stabil"
echo "   • Backup konfigurasi secara berkala"
echo "   • Monitor penggunaan resource"
echo "   • Update sistem secara rutin"
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

read -r -p "Apakah Anda ingin melihat source code installer? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo
  echo "${C_CYAN}Source code installer tersimpan di:${C_RESET} ${C_BOLD}/home/engine/project/install-vpn.sh${C_RESET}"
  echo
  echo "${C_YELLOW}Fitur yang ada di installer:${C_RESET}"
  echo "   • Welcome screen dengan ASCII art"
  echo "   • Domain validation & DNS check"
  echo "   • OS compatibility check"
  echo "   • Dependency installation dengan progress bar"
  echo "   • SSL certificate setup dengan Certbot"
  echo "   • System configuration (firewall, fail2ban, dll)"
  echo "   • VPN interface installation"
  echo "   • Finalization & backup"
  echo
  echo "${C_GREEN}Install sekarang dengan:${C_RESET}"
  echo "   ${C_BOLD}sudo bash /home/engine/project/install-vpn.sh${C_RESET}"
  echo
fi

echo "${C_BOLD}${C_GREEN}🎉 TERIMA KASIH! 🎉${C_RESET}"
echo "${C_YELLOW}Installer ini akan memudahkan setup VPN lengkap dalam satu perintah!${C_RESET}"
echo
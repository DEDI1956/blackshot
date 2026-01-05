#!/usr/bin/env bash
# ============================================================================
# VPN ALL-IN-ONE TUI PANEL (Ubuntu 20.04 / 22.04)
# Author: cto.new (generated)
#
# Catatan:
# - Script ini fokus pada TUI/menu + monitoring + beberapa operasi dasar.
# - Bagian kompleks (manajemen akun XRAY/NOOBZVPN/UDP Custom) disediakan sebagai
#   placeholder function dengan penjelasan jelas, sesuai permintaan.
# - Semua aksi memakai systemctl (restart/status) dan aman dijalankan sebagai root.
# ============================================================================

# -----------------------------
# Hardening & default behavior
# -----------------------------
set -o errexit
set -o nounset
set -o pipefail

# Jangan biarkan CTRL+C mematikan script tanpa pesan.
trap 'echo; echo "[INFO] Dibatalkan."; exit 130' INT

# -----------------------------
# Styling (colors) & utilities
# -----------------------------
# Gunakan tput agar kompatibel dengan berbagai terminal.
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

# Clear screen yang aman.
cls() { clear || printf '\033c'; }

# Pause (tekan enter).
pause() {
  echo
  read -r -p "Tekan ENTER untuk kembali..." _
}

# Print status ON/OFF dengan warna.
fmt_onoff() {
  local status="$1"
  if [[ "$status" == "ON" ]]; then
    printf "%s%s%s" "$C_GREEN" "$status" "$C_RESET"
  else
    printf "%s%s%s" "$C_RED" "$status" "$C_RESET"
  fi
}

# Safe systemctl query: jika unit tidak ada, anggap inactive.
svc_is_active() {
  local unit="$1"
  if systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "${unit}.service"; then
    systemctl is-active --quiet "$unit" && echo "ON" || echo "OFF"
    return 0
  fi

  # Beberapa service kadang memakai nama full (mis: sshd)
  if systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "$unit"; then
    systemctl is-active --quiet "$unit" && echo "ON" || echo "OFF"
    return 0
  fi

  echo "OFF"
}

# Restart service jika ada.
svc_restart_if_exists() {
  local unit="$1"
  if systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "${unit}.service"; then
    systemctl restart "$unit" || true
  elif systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "$unit"; then
    systemctl restart "$unit" || true
  fi
}

# -----------------------------
# Root check (wajib)
# -----------------------------
require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "${C_RED}${C_BOLD}[ERROR]${C_RESET} Script ini harus dijalankan sebagai root."
    echo "Jalankan: sudo bash $0"
    exit 1
  fi
}

# -----------------------------
# Header banner ASCII
# -----------------------------
print_header() {
  cls
  cat <<'BANNER'
 __      _______  _   _      _     _ _       ___  ___  ___
 \ \    / /  __ \| \ | |    | |   (_) |      |  \/  | / _ \
  \ \  / /| |  \/|  \| |    | |    _| |_ ___ | .  . |/ /_\ \
   \ \/ / | | __ | . ` |    | |   | | __/ _ \| |\/| ||  _  |
    \  /  | |_\ \| |\  |    | |___| | || (_) | |  | || | | |
     \/    \____/\_| \_/    \_____/_|\__\___/\_|  |_/\_| |_/
BANNER
  echo "${C_CYAN}${C_BOLD}VPN ALL-IN-ONE Bash TUI Panel${C_RESET}  |  Ubuntu 20.04 / 22.04"
  echo "${C_DIM}Gunakan menu bernomor. Tekan CTRL+C untuk keluar.${C_RESET}"
  echo
}

# -----------------------------
# Informasi sistem
# -----------------------------
get_os() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${PRETTY_NAME:-Ubuntu}"
  else
    uname -s
  fi
}

get_cpu_cores() {
  command -v nproc >/dev/null 2>&1 && nproc || grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo 1
}

get_uptime_pretty() {
  if command -v uptime >/dev/null 2>&1; then
    uptime -p 2>/dev/null || uptime 2>/dev/null | sed 's/^ *//' || echo "-"
  else
    echo "-"
  fi
}

get_load() {
  awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "-"
}

get_ram_usage() {
  # Output: used/total MB (percent)
  if command -v free >/dev/null 2>&1; then
    free -m | awk 'NR==2{used=$3; total=$2; pct=(total>0)?(used/total*100):0; printf "%d/%d MB (%.1f%%)", used,total,pct}'
  else
    echo "-"
  fi
}

get_public_ip() {
  # Prioritas: interface IP lokal (tanpa dependensi internet) -> fallback curl.
  local ip
  ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
  if [[ -n "${ip}" ]]; then
    echo "$ip"
    return 0
  fi
  if command -v curl >/dev/null 2>&1; then
    curl -fsS --max-time 3 https://ipinfo.io/ip 2>/dev/null || echo "-"
  else
    echo "-"
  fi
}

get_domain() {
  # Banyak installer VPN/Xray menyimpan domain di file berikut.
  local f
  for f in /etc/xray/domain /etc/v2ray/domain /usr/local/etc/xray/domain /etc/domain; do
    if [[ -s "$f" ]]; then
      head -n1 "$f" | tr -d ' \t\r\n'
      return 0
    fi
  done

  # Fallback: hostname FQDN jika ada.
  hostname -f 2>/dev/null | tr -d ' \t\r\n' || echo "-"
}

# -----------------------------
# Informasi akun (best-effort)
# -----------------------------
count_ssh_users() {
  # Hitung user "human" (UID >= 1000), shell valid, bukan nobody.
  awk -F: '($3>=1000)&&($1!="nobody")&&($7!~/(nologin|false)$/){c++} END{print c+0}' /etc/passwd
}

_xray_pick_config() {
  # Pilih config Xray paling umum.
  if [[ -s /etc/xray/config.json ]]; then
    echo "/etc/xray/config.json"; return 0
  fi
  if [[ -s /usr/local/etc/xray/config.json ]]; then
    echo "/usr/local/etc/xray/config.json"; return 0
  fi
  echo ""
}

_xray_count_by_tag_jq() {
  # Hitung clients berdasarkan inbound tag (butuh jq dan config json valid).
  local cfg="$1"; shift
  local tag
  local total=0

  for tag in "$@"; do
    # Jumlah inbound yang matching tag bisa lebih dari satu, maka dijumlah.
    local n
    n="$(jq -r --arg tag "$tag" '[.inbounds[]? | select(.tag==$tag) | (.settings.clients // []) | length] | add // 0' "$cfg" 2>/dev/null || echo 0)"
    # Pastikan angka.
    if [[ "$n" =~ ^[0-9]+$ ]]; then
      total=$((total + n))
    fi
  done

  echo "$total"
}

_xray_count_by_marker_grep() {
  # Fallback hitung dengan marker komentar yang umum dipakai script VPN premium.
  # Ini tidak selalu akurat, tapi cukup untuk dashboard.
  local cfg="$1"
  local mode="$2" # vmess|vless|trojan|ss

  case "$mode" in
    vmess)  grep -cE '^###\s' "$cfg" 2>/dev/null || echo 0 ;;
    vless)  grep -cE '^#&\s'  "$cfg" 2>/dev/null || echo 0 ;;
    trojan) grep -cE '^#!\s'  "$cfg" 2>/dev/null || echo 0 ;;
    ss)     grep -cE '^##\s'  "$cfg" 2>/dev/null || echo 0 ;;
    *) echo 0 ;;
  esac
}

count_xray_accounts() {
  # Output: 8 angka -> vmess_ws vmess_grpc vless_ws vless_grpc trojan_ws trojan_grpc ss
  local cfg
  cfg="$(_xray_pick_config)"

  if [[ -z "$cfg" ]]; then
    echo "0 0 0 0 0 0 0"
    return 0
  fi

  # Prioritas parsing JSON via jq untuk akurasi.
  if command -v jq >/dev/null 2>&1; then
    local vmess_ws vmess_grpc vless_ws vless_grpc trojan_ws trojan_grpc ss
    vmess_ws="$(_xray_count_by_tag_jq "$cfg" vmess-ws vmess_ws vmessws)"
    vmess_grpc="$(_xray_count_by_tag_jq "$cfg" vmess-grpc vmess_grpc vmessgrpc)"
    vless_ws="$(_xray_count_by_tag_jq "$cfg" vless-ws vless_ws vlessws)"
    vless_grpc="$(_xray_count_by_tag_jq "$cfg" vless-grpc vless_grpc vlessgrpc)"
    trojan_ws="$(_xray_count_by_tag_jq "$cfg" trojan-ws trojan_ws trojanws)"
    trojan_grpc="$(_xray_count_by_tag_jq "$cfg" trojan-grpc trojan_grpc trojangrpc)"
    ss="$(_xray_count_by_tag_jq "$cfg" shadowsocks ss-libev ss)"

    # Jika config tidak memakai tag standar, fallback ke marker agar tidak semua 0.
    if [[ $((vmess_ws+vmess_grpc+vless_ws+vless_grpc+trojan_ws+trojan_grpc+ss)) -eq 0 ]]; then
      vmess_ws="$(_xray_count_by_marker_grep "$cfg" vmess)"
      vless_ws="$(_xray_count_by_marker_grep "$cfg" vless)"
      trojan_ws="$(_xray_count_by_marker_grep "$cfg" trojan)"
      ss="$(_xray_count_by_marker_grep "$cfg" ss)"
      vmess_grpc=0 vless_grpc=0 trojan_grpc=0
    fi

    echo "$vmess_ws $vmess_grpc $vless_ws $vless_grpc $trojan_ws $trojan_grpc $ss"
    return 0
  fi

  # Fallback tanpa jq.
  local vmess vless trojan ss
  vmess="$(_xray_count_by_marker_grep "$cfg" vmess)"
  vless="$(_xray_count_by_marker_grep "$cfg" vless)"
  trojan="$(_xray_count_by_marker_grep "$cfg" trojan)"
  ss="$(_xray_count_by_marker_grep "$cfg" ss)"
  echo "$vmess 0 $vless 0 $trojan 0 $ss"
}

# -----------------------------
# Status service (ON/OFF)
# -----------------------------
get_services_status() {
  # Cetak status untuk dashboard.
  local ssh xray nginx haproxy dropbear udp noobz ws_epro
  ssh="$(svc_is_active ssh)"
  # Xray kadang bernama xray atau xray@. Kita cek xray saja untuk dashboard.
  xray="$(svc_is_active xray)"
  nginx="$(svc_is_active nginx)"
  haproxy="$(svc_is_active haproxy)"
  dropbear="$(svc_is_active dropbear)"

  # UDP Custom (nama service bervariasi)
  if [[ "$(svc_is_active udp-custom)" == "ON" ]]; then
    udp="ON"
  elif [[ "$(svc_is_active udp-custom-server)" == "ON" ]]; then
    udp="ON"
  elif [[ "$(svc_is_active udp-custom-client)" == "ON" ]]; then
    udp="ON"
  else
    udp="OFF"
  fi

  # NOOBZVPN (nama service bervariasi)
  if [[ "$(svc_is_active noobzvpns)" == "ON" ]]; then
    noobz="ON"
  elif [[ "$(svc_is_active noobzvpn)" == "ON" ]]; then
    noobz="ON"
  else
    noobz="OFF"
  fi

  # WS-ePro (opsional)
  if [[ "$(svc_is_active ws-epro)" == "ON" ]]; then
    ws_epro="ON"
  elif [[ "$(svc_is_active ws-epro.service)" == "ON" ]]; then
    ws_epro="ON"
  else
    ws_epro="OFF"
  fi

  printf "%s\n" "$ssh|$xray|$nginx|$haproxy|$dropbear|$udp|$noobz|$ws_epro"
}

# -----------------------------
# Dashboard renderer
# -----------------------------
render_dashboard() {
  local os cpu_cores ram load uptime ip domain
  os="$(get_os)"
  cpu_cores="$(get_cpu_cores)"
  ram="$(get_ram_usage)"
  load="$(get_load)"
  uptime="$(get_uptime_pretty)"
  ip="$(get_public_ip)"
  domain="$(get_domain)"

  local ssh_count
  ssh_count="$(count_ssh_users)"

  local vmess_ws vmess_grpc vless_ws vless_grpc trojan_ws trojan_grpc ss_count
  read -r vmess_ws vmess_grpc vless_ws vless_grpc trojan_ws trojan_grpc ss_count < <(count_xray_accounts)

  local svc
  svc="$(get_services_status)"
  IFS='|' read -r svc_ssh svc_xray svc_nginx svc_haproxy svc_dropbear svc_udp svc_noobz svc_wsepro <<<"$svc"

  # Layout dashboard.
  echo "${C_BOLD}${C_BLUE}┌──────────────────────────────────────────────────────────────────────────────┐${C_RESET}"
  printf "%s%s%-78s%s\n" "$C_BOLD" "$C_BLUE" "│ SYSTEM INFORMATION" "$C_RESET"
  echo "${C_BOLD}${C_BLUE}├──────────────────────────────────────────────────────────────────────────────┤${C_RESET}"
  printf "${C_BLUE}│${C_RESET} OS        : %-62s ${C_BLUE}│${C_RESET}\n" "$os"
  printf "${C_BLUE}│${C_RESET} CPU       : %-62s ${C_BLUE}│${C_RESET}\n" "${cpu_cores} Core"
  printf "${C_BLUE}│${C_RESET} RAM       : %-62s ${C_BLUE}│${C_RESET}\n" "$ram"
  printf "${C_BLUE}│${C_RESET} LOAD      : %-62s ${C_BLUE}│${C_RESET}\n" "$load"
  printf "${C_BLUE}│${C_RESET} UPTIME    : %-62s ${C_BLUE}│${C_RESET}\n" "$uptime"
  printf "${C_BLUE}│${C_RESET} IP VPS    : %-62s ${C_BLUE}│${C_RESET}\n" "$ip"
  printf "${C_BLUE}│${C_RESET} DOMAIN    : %-62s ${C_BLUE}│${C_RESET}\n" "$domain"
  echo "${C_BOLD}${C_BLUE}├──────────────────────────────────────────────────────────────────────────────┤${C_RESET}"
  printf "%s%s%-78s%s\n" "$C_BOLD" "$C_BLUE" "│ ACCOUNT INFORMATION" "$C_RESET"
  echo "${C_BOLD}${C_BLUE}├──────────────────────────────────────────────────────────────────────────────┤${C_RESET}"
  printf "${C_BLUE}│${C_RESET} SSH Users          : %-49s ${C_BLUE}│${C_RESET}\n" "$ssh_count"
  printf "${C_BLUE}│${C_RESET} VMESS (WS / gRPC)  : %-49s ${C_BLUE}│${C_RESET}\n" "${vmess_ws} / ${vmess_grpc}"
  printf "${C_BLUE}│${C_RESET} VLESS (WS / gRPC)  : %-49s ${C_BLUE}│${C_RESET}\n" "${vless_ws} / ${vless_grpc}"
  printf "${C_BLUE}│${C_RESET} TROJAN(WS / gRPC)  : %-49s ${C_BLUE}│${C_RESET}\n" "${trojan_ws} / ${trojan_grpc}"
  printf "${C_BLUE}│${C_RESET} SHADOWSOCKS (opt)  : %-49s ${C_BLUE}│${C_RESET}\n" "${ss_count}"
  echo "${C_BOLD}${C_BLUE}├──────────────────────────────────────────────────────────────────────────────┤${C_RESET}"
  printf "%s%s%-78s%s\n" "$C_BOLD" "$C_BLUE" "│ SERVICE STATUS" "$C_RESET"
  echo "${C_BOLD}${C_BLUE}├──────────────────────────────────────────────────────────────────────────────┤${C_RESET}"
  printf "${C_BLUE}│${C_RESET} SSH      : %-10s XRAY     : %-10s NGINX    : %-10s ${C_BLUE}│${C_RESET}\n" "$(fmt_onoff "$svc_ssh")" "$(fmt_onoff "$svc_xray")" "$(fmt_onoff "$svc_nginx")"
  printf "${C_BLUE}│${C_RESET} HAPROXY  : %-10s DROPBEAR : %-10s UDP      : %-10s ${C_BLUE}│${C_RESET}\n" "$(fmt_onoff "$svc_haproxy")" "$(fmt_onoff "$svc_dropbear")" "$(fmt_onoff "$svc_udp")"
  printf "${C_BLUE}│${C_RESET} NOOBZVPN : %-10s WS-ePro  : %-10s %-23s ${C_BLUE}│${C_RESET}\n" "$(fmt_onoff "$svc_noobz")" "$(fmt_onoff "$svc_wsepro")" ""
  echo "${C_BOLD}${C_BLUE}└──────────────────────────────────────────────────────────────────────────────┘${C_RESET}"
  echo
}

# -----------------------------
# Menu utama
# -----------------------------
print_main_menu() {
  cat <<EOF
${C_BOLD}${C_YELLOW}MAIN MENU${C_RESET}

 [01] SSH MENU
 [02] VMESS MENU
 [03] VLESS MENU
 [04] TROJAN MENU
 [05] AKUN NOOBZVPN
 [06] SS - LIBEV
 [07] INSTALL UDP
 [08] BACKUP / RESTORE
 [09] GOTO X RAM
 [10] RESTART ALL
 [11] TELE BOT
 [12] UPDATE MENU
 [13] RUNNING SERVICE
 [14] INFO PORT
 [15] MENU BOT
 [16] CHANGE DOMAIN
 [17] FIX CERT DOMAIN
 [18] CHANGE BANNER
 [19] RESTART BANNER
 [20] SPEEDTEST
 [21] EKSTRAK MENU

 [00] EXIT
EOF
}

# -----------------------------
# Sub-menu: SSH
# -----------------------------
ssh_menu() {
  while true; do
    print_header
    render_dashboard

    cat <<EOF
${C_BOLD}${C_YELLOW}SSH MENU${C_RESET}

 [1] Add SSH User
 [2] Delete SSH User
 [3] Renew SSH User (Extend Expiry)
 [4] List SSH Users
 [5] Show Logged-in Users (who)

 [0] Back
EOF

    read -r -p "Select: " opt
    case "$opt" in
      1) ssh_add_user ;;
      2) ssh_delete_user ;;
      3) ssh_renew_user ;;
      4) ssh_list_users ;;
      5) ssh_show_logged_in ;;
      0) return 0 ;;
      *) echo "Pilihan tidak valid."; pause ;;
    esac
  done
}

ssh_add_user() {
  # Menambah akun SSH Linux standar (tanpa mengubah konfigurasi daemon).
  print_header
  echo "${C_BOLD}Add SSH User${C_RESET}"
  echo

  local user pass days exp_date
  read -r -p "Username: " user
  if [[ -z "$user" ]]; then
    echo "Username kosong."; pause; return 0
  fi
  if id -u "$user" >/dev/null 2>&1; then
    echo "User sudah ada."; pause; return 0
  fi

  read -r -s -p "Password: " pass
  echo
  read -r -p "Masa aktif (hari): " days
  if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echo "Hari harus angka."; pause; return 0
  fi

  exp_date="$(date -d "+${days} days" +%Y-%m-%d)"

  useradd -m -s /bin/bash -e "$exp_date" "$user"
  echo "${user}:${pass}" | chpasswd

  echo
  echo "${C_GREEN}[OK]${C_RESET} User dibuat."
  echo " Username : $user"
  echo " Expired  : $exp_date"
  pause
}

ssh_delete_user() {
  # Menghapus akun SSH.
  print_header
  echo "${C_BOLD}Delete SSH User${C_RESET}"
  echo

  local user
  read -r -p "Username: " user
  if [[ -z "$user" ]]; then
    echo "Username kosong."; pause; return 0
  fi
  if ! id -u "$user" >/dev/null 2>&1; then
    echo "User tidak ditemukan."; pause; return 0
  fi

  userdel -r "$user" 2>/dev/null || userdel "$user"

  echo
  echo "${C_GREEN}[OK]${C_RESET} User dihapus: $user"
  pause
}

ssh_renew_user() {
  # Perpanjang masa aktif akun SSH dengan chage.
  print_header
  echo "${C_BOLD}Renew SSH User${C_RESET}"
  echo

  local user days exp_date
  read -r -p "Username: " user
  if [[ -z "$user" ]]; then
    echo "Username kosong."; pause; return 0
  fi
  if ! id -u "$user" >/dev/null 2>&1; then
    echo "User tidak ditemukan."; pause; return 0
  fi

  read -r -p "Tambahkan masa aktif (hari): " days
  if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echo "Hari harus angka."; pause; return 0
  fi

  # Ambil expiry existing, lalu tambah.
  local cur_exp
  cur_exp="$(chage -l "$user" | awk -F: '/Account expires/{gsub(/^ +/,"",$2);print $2}')"

  if [[ "$cur_exp" == "never" || -z "$cur_exp" ]]; then
    exp_date="$(date -d "+${days} days" +%Y-%m-%d)"
  else
    exp_date="$(date -d "${cur_exp} +${days} days" +%Y-%m-%d)"
  fi

  chage -E "$exp_date" "$user"

  echo
  echo "${C_GREEN}[OK]${C_RESET} Expiry diupdate."
  echo " Username : $user"
  echo " Expired  : $exp_date"
  pause
}

ssh_list_users() {
  # Tampilkan list user human + expiry.
  print_header
  echo "${C_BOLD}List SSH Users${C_RESET}"
  echo

  printf "%-20s %-12s\n" "USERNAME" "EXPIRES"
  printf "%-20s %-12s\n" "--------" "-------"

  # Ambil user human dari /etc/passwd.
  while IFS=: read -r uname _ uid _ _ _ shell; do
    [[ "$uid" -ge 1000 ]] || continue
    [[ "$uname" != "nobody" ]] || continue
    [[ "$shell" =~ (nologin|false)$ ]] && continue

    # Expiry via chage.
    local exp
    exp="$(chage -l "$uname" 2>/dev/null | awk -F: '/Account expires/{gsub(/^ +/,"",$2);print $2}')"
    [[ -n "$exp" ]] || exp="-"
    printf "%-20s %-12s\n" "$uname" "$exp"
  done < /etc/passwd

  pause
}

ssh_show_logged_in() {
  print_header
  echo "${C_BOLD}Logged-in Users (who)${C_RESET}"
  echo
  who || true
  pause
}

# -----------------------------
# Sub-menu: VMESS / VLESS / TROJAN (XRAY)
# -----------------------------
# Catatan:
# - Manajemen akun XRAY sangat tergantung pada struktur config yang dipakai
#   (single config.json / split config / template komentar, dll).
# - Untuk menjaga script ini aman dan portable, di bawah ini disediakan
#   placeholder function yang bisa Anda isi sesuai installer XRAY Anda.

vmess_menu() { xray_placeholder_menu "VMESS"; }
vless_menu() { xray_placeholder_menu "VLESS"; }
trojan_menu() { xray_placeholder_menu "TROJAN"; }

xray_placeholder_menu() {
  local proto="$1"
  while true; do
    print_header
    render_dashboard

    cat <<EOF
${C_BOLD}${C_YELLOW}${proto} MENU (XRAY)${C_RESET}

 [1] Add ${proto} Account
 [2] Delete ${proto} Account
 [3] Renew ${proto} Account
 [4] List ${proto} Accounts

 [0] Back

${C_DIM}Placeholder:${C_RESET}
- Implementasikan CRUD akun dengan mengedit /etc/xray/config.json
- Setelah perubahan, restart XRAY: systemctl restart xray
EOF

    read -r -p "Select: " opt
    case "$opt" in
      1|2|3|4)
        echo
        echo "${C_YELLOW}[TODO]${C_RESET} Implementasi ${proto} account management belum diaktifkan."
        echo "Silakan sesuaikan dengan format config XRAY Anda."
        pause
        ;;
      0) return 0 ;;
      *) echo "Pilihan tidak valid."; pause ;;
    esac
  done
}

# -----------------------------
# NOOBZVPN (placeholder)
# -----------------------------
noobzvpn_menu() {
  while true; do
    print_header
    render_dashboard

    cat <<EOF
${C_BOLD}${C_YELLOW}AKUN NOOBZVPN${C_RESET}

 [1] Add NOOBZVPN User
 [2] Delete NOOBZVPN User
 [3] List NOOBZVPN Users
 [4] Restart NOOBZVPN Service

 [0] Back

${C_DIM}Placeholder:${C_RESET}
- NOOBZVPN memiliki format akun/config yang berbeda-beda.
- Isi implementasi sesuai binary/service yang Anda gunakan.
EOF

    read -r -p "Select: " opt
    case "$opt" in
      1|2|3)
        echo
        echo "${C_YELLOW}[TODO]${C_RESET} Implementasi NOOBZVPN account management belum tersedia."
        pause
        ;;
      4)
        svc_restart_if_exists noobzvpns
        svc_restart_if_exists noobzvpn
        echo
        echo "${C_GREEN}[OK]${C_RESET} Restart NOOBZVPN (jika service ada)."
        pause
        ;;
      0) return 0 ;;
      *) echo "Pilihan tidak valid."; pause ;;
    esac
  done
}

# -----------------------------
# Shadowsocks-libev (opsional)
# -----------------------------
ss_libev_menu() {
  while true; do
    print_header
    render_dashboard

    cat <<EOF
${C_BOLD}${C_YELLOW}SS - LIBEV${C_RESET}

 [1] Check ss-libev Service Status
 [2] Restart ss-libev

 [0] Back

${C_DIM}Catatan:${C_RESET}
- Jika Anda memakai Shadowsocks via XRAY, gunakan menu XRAY.
- Jika memakai shadowsocks-libev, service biasanya bernama: shadowsocks-libev
EOF

    read -r -p "Select: " opt
    case "$opt" in
      1)
        local st
        st="$(svc_is_active shadowsocks-libev)"
        echo
        echo "shadowsocks-libev: $(fmt_onoff "$st")"
        pause
        ;;
      2)
        svc_restart_if_exists shadowsocks-libev
        echo
        echo "${C_GREEN}[OK]${C_RESET} Restart shadowsocks-libev (jika service ada)."
        pause
        ;;
      0) return 0 ;;
      *) echo "Pilihan tidak valid."; pause ;;
    esac
  done
}

# -----------------------------
# Install UDP Custom (placeholder)
# -----------------------------
udp_install_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}INSTALL UDP (UDP CUSTOM)${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- UDP Custom umumnya membutuhkan binary + konfigurasi port + systemd service.
- Karena implementasi berbeda-beda (udp-custom, badvpn, udp-request, dll),
  script ini tidak menginstall otomatis.

Yang bisa Anda lakukan:
1) Pasang service udp-custom Anda (manual / script installer Anda)
2) Pastikan ada systemd unit bernama: udp-custom / udp-custom-server
3) Dashboard akan otomatis menampilkan status ON/OFF.
EOF
  pause
}

# -----------------------------
# Backup / Restore
# -----------------------------
backup_restore_menu() {
  while true; do
    print_header
    render_dashboard

    cat <<EOF
${C_BOLD}${C_YELLOW}BACKUP / RESTORE${C_RESET}

 [1] Create Backup (tar.gz)
 [2] Restore Backup (tar.gz)

 [0] Back
EOF

    read -r -p "Select: " opt
    case "$opt" in
      1) do_backup ;;
      2) do_restore ;;
      0) return 0 ;;
      *) echo "Pilihan tidak valid."; pause ;;
    esac
  done
}

do_backup() {
  # Backup direktori umum konfigurasi VPN/Reverse Proxy.
  print_header
  echo "${C_BOLD}Create Backup${C_RESET}"
  echo

  local ts out
  ts="$(date +%Y%m%d-%H%M%S)"
  out="/root/vpn-backup-${ts}.tar.gz"

  # Daftar path yang dibackup (yang ada saja).
  local paths=()
  for p in /etc/xray /usr/local/etc/xray /etc/nginx /etc/haproxy /etc/ssh /etc/dropbear /etc/letsencrypt /var/www; do
    [[ -e "$p" ]] && paths+=("$p")
  done

  if [[ ${#paths[@]} -eq 0 ]]; then
    echo "Tidak ada direktori konfigurasi yang ditemukan untuk dibackup."
    pause
    return 0
  fi

  tar -czf "$out" "${paths[@]}" 2>/dev/null || true

  echo "${C_GREEN}[OK]${C_RESET} Backup dibuat: $out"
  echo
  echo "Simpan file ini dengan aman."
  pause
}

do_restore() {
  # Restore backup tar.gz.
  print_header
  echo "${C_BOLD}Restore Backup${C_RESET}"
  echo

  local file
  read -r -p "Path file backup (.tar.gz): " file
  if [[ -z "$file" || ! -f "$file" ]]; then
    echo "File tidak ditemukan."; pause; return 0
  fi

  echo
  echo "${C_YELLOW}[WARN]${C_RESET} Restore akan menimpa konfigurasi yang ada."
  read -r -p "Lanjutkan? (y/N): " yn
  if [[ "${yn,,}" != "y" ]]; then
    echo "Dibatalkan."; pause; return 0
  fi

  tar -xzf "$file" -C / 2>/dev/null || true

  echo
  echo "${C_GREEN}[OK]${C_RESET} Restore selesai."
  echo "Disarankan restart service terkait."
  pause
}

# -----------------------------
# GOTO X RAM (placeholder)
# -----------------------------
goto_x_ram_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}GOTO X RAM${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- Pada beberapa script VPN premium, "X RAM" merujuk ke tool monitoring RAM/
  swap/limiter tertentu atau shortcut ke menu optimasi.
- Anda bisa isi menu ini untuk:
  - install zram
  - set swappiness
  - cache drop
  - monitoring proses pemakaian RAM
EOF
  pause
}

# -----------------------------
# Restart ALL
# -----------------------------
restart_all_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}RESTART ALL${C_RESET}"
  echo
  echo "Service yang akan dicoba restart: ssh, xray, nginx, haproxy, dropbear, udp-custom, noobzvpn"
  echo
  read -r -p "Lanjutkan? (y/N): " yn
  if [[ "${yn,,}" != "y" ]]; then
    echo "Dibatalkan."; pause; return 0
  fi

  svc_restart_if_exists ssh
  svc_restart_if_exists xray
  svc_restart_if_exists nginx
  svc_restart_if_exists haproxy
  svc_restart_if_exists dropbear
  svc_restart_if_exists udp-custom
  svc_restart_if_exists udp-custom-server
  svc_restart_if_exists noobzvpns
  svc_restart_if_exists noobzvpn

  echo
  echo "${C_GREEN}[OK]${C_RESET} Restart all executed (yang tersedia saja)."
  pause
}

# -----------------------------
# Tele Bot / Menu Bot (placeholder)
# -----------------------------
tele_bot_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}TELE BOT${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- Menu ini biasanya untuk integrasi Telegram Bot:
  - Notifikasi user login
  - Create user via bot
  - Monitor service

Rekomendasi implementasi:
- Simpan BOT_TOKEN dan CHAT_ID di /etc/vpn-panel/telegram.env
- Buat service systemd yang menjalankan bot handler (python/node/bash)
EOF
  pause
}

menu_bot_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}MENU BOT${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- Isi sesuai bot yang Anda gunakan.
- Contoh: start/stop service bot, set token, set chat id.
EOF
  pause
}

# -----------------------------
# Update Menu (placeholder)
# -----------------------------
update_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}UPDATE MENU${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- Mekanisme update biasanya dilakukan via git pull atau download script baru.
- Karena lokasi install tiap VPS berbeda, script ini tidak memaksa update.

Jika Anda menyimpan script ini di /usr/local/sbin/menu, Anda bisa:
- git clone repo Anda -> symlink ke /usr/local/sbin/menu
- atau curl URL raw -> overwrite -> chmod +x
EOF
  pause
}

# -----------------------------
# Running Service
# -----------------------------
running_service_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}RUNNING SERVICE${C_RESET}"
  echo

  # Tampilkan ringkas service yang relevan.
  local units=(ssh xray nginx haproxy dropbear udp-custom udp-custom-server noobzvpns noobzvpn shadowsocks-libev)
  local u
  for u in "${units[@]}"; do
    local st
    st="$(svc_is_active "$u")"
    printf "%-18s : %s\n" "$u" "$(fmt_onoff "$st")"
  done

  echo
  echo "Detail systemctl (optional):"
  echo "  systemctl --type=service --state=running"
  pause
}

# -----------------------------
# Info Port
# -----------------------------
info_port_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}INFO PORT${C_RESET}"
  echo

  if command -v ss >/dev/null 2>&1; then
    echo "Listening ports (ss -tulpn):"
    echo
    ss -tulpn || true
  elif command -v netstat >/dev/null 2>&1; then
    echo "Listening ports (netstat -tulpn):"
    echo
    netstat -tulpn || true
  else
    echo "Tool ss/netstat tidak ditemukan. Install paket: iproute2 / net-tools"
  fi

  pause
}

# -----------------------------
# Change Domain
# -----------------------------
change_domain_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}CHANGE DOMAIN${C_RESET}"
  echo

  local domain
  read -r -p "Masukkan domain baru (contoh: vpn.example.com): " domain
  domain="$(echo "$domain" | tr -d ' \t\r\n')"

  if [[ -z "$domain" ]]; then
    echo "Domain kosong."; pause; return 0
  fi

  # Validasi sederhana (bukan validator DNS penuh).
  if ! [[ "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Format domain terlihat tidak valid."; pause; return 0
  fi

  mkdir -p /etc/xray /etc/v2ray || true
  echo "$domain" > /etc/xray/domain
  echo "$domain" > /etc/v2ray/domain

  echo
  echo "${C_GREEN}[OK]${C_RESET} Domain diset ke: $domain"
  echo "Catatan: Anda mungkin perlu regenerate sertifikat (menu 17) dan reload NGINX/HAPROXY.";
  pause
}

# -----------------------------
# Fix Cert Domain (placeholder dengan guideline)
# -----------------------------
fix_cert_domain_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}FIX CERT DOMAIN${C_RESET}"
  echo

  local domain
  domain="$(get_domain)"
  echo "Domain saat ini: ${C_CYAN}${domain}${C_RESET}"
  echo

  cat <<EOF
${C_DIM}Placeholder (ACME)${C_RESET}

Sertifikat TLS biasanya dibuat menggunakan salah satu:
- acme.sh (recommended)
- certbot

Contoh alur (acme.sh) secara konsep:
1) Stop service yang memakai port 80 (nginx/haproxy) sementara
2) Issue cert untuk domain
3) Install cert ke lokasi yang dipakai XRAY/NGINX
4) Start ulang service

Karena tiap server bisa berbeda, script ini tidak otomatis mengeksekusi issuance.
EOF

  echo
  if command -v acme.sh >/dev/null 2>&1; then
    echo "acme.sh terdeteksi di PATH. Anda bisa jalankan manual:"
    echo "  acme.sh --issue -d ${domain} --standalone"
    echo "  acme.sh --install-cert -d ${domain} --key-file /etc/xray/xray.key --fullchain-file /etc/xray/xray.crt"
  elif [[ -x /root/.acme.sh/acme.sh ]]; then
    echo "acme.sh terdeteksi di /root/.acme.sh. Anda bisa jalankan manual:"
    echo "  /root/.acme.sh/acme.sh --issue -d ${domain} --standalone"
    echo "  /root/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /etc/xray/xray.key --fullchain-file /etc/xray/xray.crt"
  else
    echo "acme.sh tidak terdeteksi. Jika ingin install:"
    echo "  curl https://get.acme.sh | sh"
  fi

  pause
}

# -----------------------------
# Change Banner (SSH)
# -----------------------------
change_banner_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}CHANGE BANNER${C_RESET}"
  echo

  local file
  file="/etc/issue.net"

  echo "Banner SSH biasanya mengambil isi file: $file"
  echo
  echo "Masukkan banner baru (akhiri dengan baris tunggal: END)"
  echo "------------------------------------------------------"

  local tmp
  tmp="$(mktemp)"
  while IFS= read -r line; do
    [[ "$line" == "END" ]] && break
    echo "$line" >> "$tmp"
  done

  mv "$tmp" "$file"
  chmod 0644 "$file" || true

  # Pastikan sshd_config mengarah ke /etc/issue.net
  if [[ -f /etc/ssh/sshd_config ]]; then
    if grep -qE '^\s*Banner\s+' /etc/ssh/sshd_config; then
      sed -i 's@^\s*Banner\s\+.*@Banner /etc/issue.net@g' /etc/ssh/sshd_config
    else
      echo 'Banner /etc/issue.net' >> /etc/ssh/sshd_config
    fi
  fi

  echo
  echo "${C_GREEN}[OK]${C_RESET} Banner diupdate. Silakan restart SSH (menu 19) agar efektif."
  pause
}

# -----------------------------
# Restart Banner (restart ssh + dropbear)
# -----------------------------
restart_banner_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}RESTART BANNER${C_RESET}"
  echo

  svc_restart_if_exists ssh
  svc_restart_if_exists dropbear

  echo "${C_GREEN}[OK]${C_RESET} SSH/Dropbear restart (yang tersedia saja)."
  pause
}

# -----------------------------
# Speedtest
# -----------------------------
speedtest_menu() {
  print_header
  render_dashboard

  echo "${C_BOLD}${C_YELLOW}SPEEDTEST${C_RESET}"
  echo

  if command -v speedtest >/dev/null 2>&1; then
    speedtest || true
    pause
    return 0
  fi

  if command -v speedtest-cli >/dev/null 2>&1; then
    speedtest-cli || true
    pause
    return 0
  fi

  echo "Tool speedtest belum ada. Install cepat via apt:"
  echo "  apt-get update -y && apt-get install -y speedtest-cli"
  echo
  read -r -p "Install sekarang? (y/N): " yn
  if [[ "${yn,,}" == "y" ]]; then
    apt-get update -y
    apt-get install -y speedtest-cli
    speedtest-cli || true
  fi

  pause
}

# -----------------------------
# Ekstrak Menu (placeholder)
# -----------------------------
ekstrak_menu() {
  print_header
  render_dashboard

  cat <<EOF
${C_BOLD}${C_YELLOW}EKSTRAK MENU${C_RESET}

${C_DIM}Placeholder:${C_RESET}
- Pada beberapa panel, menu ini untuk mengekstrak/addon script tambahan.
- Anda bisa isi untuk:
  - import modul menu dari /usr/local/lib/vpn-panel/modules
  - download tambahan (badvpn, stunnel, openvpn tools, dll)
EOF
  pause
}

# -----------------------------
# Main loop input menu (while true)
# -----------------------------
main() {
  require_root

  while true; do
    print_header
    render_dashboard
    print_main_menu

    read -r -p "Select menu: " menu

    case "$menu" in
      1|01) ssh_menu ;;
      2|02) vmess_menu ;;
      3|03) vless_menu ;;
      4|04) trojan_menu ;;
      5|05) noobzvpn_menu ;;
      6|06) ss_libev_menu ;;
      7|07) udp_install_menu ;;
      8|08) backup_restore_menu ;;
      9|09) goto_x_ram_menu ;;
      10) restart_all_menu ;;
      11) tele_bot_menu ;;
      12) update_menu ;;
      13) running_service_menu ;;
      14) info_port_menu ;;
      15) menu_bot_menu ;;
      16) change_domain_menu ;;
      17) fix_cert_domain_menu ;;
      18) change_banner_menu ;;
      19) restart_banner_menu ;;
      20) speedtest_menu ;;
      21) ekstrak_menu ;;
      0|00)
        echo "Keluar..."
        exit 0
        ;;
      *)
        echo "Pilihan tidak valid.";
        pause
        ;;
    esac
  done
}

main "$@"

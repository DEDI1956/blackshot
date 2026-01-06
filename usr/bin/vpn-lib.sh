#!/usr/bin/env bash
# ============================================================================
# VPN ALL-IN-ONE Library Functions
# Shared functions untuk semua menu VPN
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

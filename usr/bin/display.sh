#!/usr/bin/env bash
# ============================================================================
# Display / UI module
# Berisi seluruh helper tampilan untuk panel VPN (header, dashboard, box layout)
# ============================================================================

# Module ini didesain untuk di-source dari vpn-lib.sh.
# Jangan mengubah shell options (set -euo pipefail) di sini.

ui__is_tty() {
  [[ -t 1 ]]
}

ui__has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ui__init_colors() {
  if [[ -n "${C_RESET-}" ]]; then
    return 0
  fi

  if ui__is_tty && ui__has_cmd tput; then
    C_RESET="$(tput sgr0 || true)"
    C_BOLD="$(tput bold || true)"
    C_DIM="$(tput dim || true)"
    C_RED="$(tput setaf 1 || true)"
    C_GREEN="$(tput setaf 2 || true)"
    C_YELLOW="$(tput setaf 3 || true)"
    C_BLUE="$(tput setaf 4 || true)"
    C_MAGENTA="$(tput setaf 5 || true)"
    C_CYAN="$(tput setaf 6 || true)"
    C_WHITE="$(tput setaf 7 || true)"
  else
    C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE=''
  fi
}

ui__is_utf8() {
  if ui__has_cmd locale; then
    [[ "$(locale charmap 2>/dev/null || true)" == "UTF-8" ]]
  else
    return 1
  fi
}

ui__init_borders() {
  if ui__is_utf8; then
    UI_TL='┌' UI_TR='┐' UI_BL='└' UI_BR='┘'
    UI_H='─' UI_V='│'
    UI_TJ='┬' UI_BJ='┴' UI_LJ='├' UI_RJ='┤' UI_X='┼'
  else
    UI_TL='+' UI_TR='+' UI_BL='+' UI_BR='+'
    UI_H='-' UI_V='|'
    UI_TJ='+' UI_BJ='+' UI_LJ='+' UI_RJ='+' UI_X='+'
  fi
}

ui_term_cols() {
  local cols=80

  if ui__is_tty && ui__has_cmd tput; then
    cols="$(tput cols 2>/dev/null || echo 80)"
  fi

  if ! [[ "$cols" =~ ^[0-9]+$ ]]; then
    cols=80
  fi

  # Jangan pernah melebihi lebar terminal agar tidak wrap.
  # Batasi maksimum agar tampilan tetap rapi di terminal sangat lebar.
  if (( cols > 96 )); then
    cols=96
  fi

  echo "$cols"
}

ui__repeat() {
  local ch="$1"
  local n="$2"
  local out=''
  local i

  for ((i = 0; i < n; i++)); do
    out+="$ch"
  done
  printf '%s' "$out"
}

ui__strip_ansi() {
  # Strip ANSI CSI sequences (best-effort).
  printf '%s' "$1" | sed -r 's/\x1B\[[0-9;]*[[:alpha:]]//g'
}

ui__vlen() {
  local s
  s="$(ui__strip_ansi "$1")"
  printf '%s' "${#s}"
}

ui__ellipsis() {
  local s="$1"
  local max="$2"

  if (( max <= 0 )); then
    printf ''
    return 0
  fi

  if (( ${#s} <= max )); then
    printf '%s' "$s"
    return 0
  fi

  if (( max <= 3 )); then
    printf '%.*s' "$max" "$s"
    return 0
  fi

  printf '%.*s...' "$((max - 3))" "$s"
}

ui__box_top() {
  local w="$1"
  printf '%s%s%s%s%s\n' "$C_BOLD" "$C_BLUE" "$UI_TL" "$(ui__repeat "$UI_H" "$((w - 2))")" "$UI_TR$C_RESET"
}

ui__box_bottom() {
  local w="$1"
  printf '%s%s%s%s%s\n' "$C_BOLD" "$C_BLUE" "$UI_BL" "$(ui__repeat "$UI_H" "$((w - 2))")" "$UI_BR$C_RESET"
}

ui__box_sep() {
  local w="$1"
  printf '%s%s%s%s%s\n' "$C_BOLD" "$C_BLUE" "$UI_LJ" "$(ui__repeat "$UI_H" "$((w - 2))")" "$UI_RJ$C_RESET"
}

ui__box_line() {
  local w="$1"
  local content="$2"

  local inner=$((w - 2))
  local clen
  clen="$(ui__vlen "$content")"

  # Truncate plain text only (best-effort) jika terlalu panjang.
  if (( clen > inner )); then
    content="$(ui__ellipsis "$(ui__strip_ansi "$content")" "$inner")"
    clen=${#content}
  fi

  printf '%s%s%s' "$C_BOLD" "$C_BLUE" "$UI_V$C_RESET"
  printf '%s' "$content"
  printf '%*s' "$((inner - clen))" ''
  printf '%s%s%s\n' "$C_BOLD" "$C_BLUE" "$UI_V$C_RESET"
}

ui__box_title_line() {
  local w="$1"
  local title="$2"

  local inner=$((w - 2))
  local pad_left pad_right
  local tlen=${#title}

  if (( tlen >= inner )); then
    ui__box_line "$w" "${C_BOLD}${title}${C_RESET}"
    return 0
  fi

  pad_left=$(((inner - tlen) / 2))
  pad_right=$((inner - tlen - pad_left))

  ui__box_line "$w" "$(printf '%*s%s%*s' "$pad_left" '' "${C_BOLD}${title}${C_RESET}" "$pad_right" '')"
}

ui_kv_line() {
  local w="$1"
  local key="$2"
  local value="$3"
  local key_w=12

  local inner=$((w - 2))
  local prefix_len=$((1 + key_w + 3)) # " " + key + " : "
  local max_val=$((inner - prefix_len))

  value="$(ui__ellipsis "$value" "$max_val")"
  ui__box_line "$w" " $(printf '%-*s : %s' "$key_w" "$key" "$value")"
}

ui_status_row() {
  local w="$1"
  local l1="$2" s1="$3" l2="$4" s2="$5" l3="$6" s3="$7"

  ui__box_line "$w" " $(printf '%-8s : %-10s %-8s : %-10s %-8s : %-10s' "$l1" "$s1" "$l2" "$s2" "$l3" "$s3")"
}

cls() {
  clear >/dev/null 2>&1 || printf '\033c'
}

pause() {
  echo
  read -r -p "Tekan ENTER untuk kembali..." _
}

fmt_onoff() {
  local status="$1"
  if [[ "$status" == "ON" ]]; then
    printf '%s%s%s' "$C_GREEN" "$status" "$C_RESET"
  else
    printf '%s%s%s' "$C_RED" "$status" "$C_RESET"
  fi
}

ui_print_header() {
  ui__init_colors
  ui__init_borders

  cls

  local w
  w="$(ui_term_cols)"

  ui__box_top "$w"
  ui__box_title_line "$w" "BLACKSHOT VPN PANEL"
  ui__box_line "$w" " ${C_DIM}Premium CLI Dashboard - Stable Layout - ${C_RESET}$(date '+%Y-%m-%d %H:%M')"
  ui__box_bottom "$w"
  echo
}

ui_render_dashboard() {
  ui__init_colors
  ui__init_borders

  local os="$1" cpu_cores="$2" ram="$3" load="$4" uptime="$5" ip="$6" domain="$7" ssh_count="$8"
  local vmess_ws="$9" vmess_grpc="${10}" vless_ws="${11}" vless_grpc="${12}" trojan_ws="${13}" trojan_grpc="${14}" ss_count="${15}" svc="${16}"

  local svc_ssh svc_xray svc_nginx svc_haproxy svc_dropbear svc_udp svc_noobz svc_wsepro
  IFS='|' read -r svc_ssh svc_xray svc_nginx svc_haproxy svc_dropbear svc_udp svc_noobz svc_wsepro <<<"$svc"

  local w
  w="$(ui_term_cols)"

  ui__box_top "$w"
  ui__box_title_line "$w" "DASHBOARD"
  ui__box_sep "$w"

  ui__box_line "$w" " ${C_BOLD}${C_CYAN}SYSTEM INFORMATION${C_RESET}"
  ui_kv_line "$w" "OS" "$os"
  ui_kv_line "$w" "CPU" "${cpu_cores} Core"
  ui_kv_line "$w" "RAM" "$ram"
  ui_kv_line "$w" "LOAD" "$load"
  ui_kv_line "$w" "UPTIME" "$uptime"
  ui_kv_line "$w" "IP VPS" "$ip"
  ui_kv_line "$w" "DOMAIN" "$domain"

  ui__box_sep "$w"

  ui__box_line "$w" " ${C_BOLD}${C_CYAN}ACCOUNT INFORMATION${C_RESET}"
  ui_kv_line "$w" "SSH" "$ssh_count user"
  ui_kv_line "$w" "VMESS" "${vmess_ws} WS / ${vmess_grpc} gRPC"
  ui_kv_line "$w" "VLESS" "${vless_ws} WS / ${vless_grpc} gRPC"
  ui_kv_line "$w" "TROJAN" "${trojan_ws} WS / ${trojan_grpc} gRPC"
  ui_kv_line "$w" "SS" "$ss_count"

  ui__box_sep "$w"

  ui__box_line "$w" " ${C_BOLD}${C_CYAN}SERVICE STATUS${C_RESET}"
  ui_status_row "$w" "SSH" "$(fmt_onoff "$svc_ssh")" "XRAY" "$(fmt_onoff "$svc_xray")" "NGINX" "$(fmt_onoff "$svc_nginx")"
  ui_status_row "$w" "HAPROXY" "$(fmt_onoff "$svc_haproxy")" "DROPBEAR" "$(fmt_onoff "$svc_dropbear")" "UDP" "$(fmt_onoff "$svc_udp")"
  ui_status_row "$w" "NOOBZVPN" "$(fmt_onoff "$svc_noobz")" "WS-ePro" "$(fmt_onoff "$svc_wsepro")" "" ""

  ui__box_bottom "$w"
  echo
}

# Jika file ini dieksekusi langsung, tampilkan demo singkat.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ui_print_header
  echo "${C_YELLOW}[INFO]${C_RESET} display.sh adalah module UI dan biasanya di-source dari vpn-lib.sh"
fi

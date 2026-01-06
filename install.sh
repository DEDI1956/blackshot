#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/DEDI1956/blackshot.git"
INSTALL_DIR="/opt/blackshot"
SRC_BIN_DIR="${INSTALL_DIR}/usr/bin"
DEST_BIN_DIR="/usr/bin"

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "[ERROR] Script ini harus dijalankan sebagai root."
    echo "Jalankan: sudo bash <(curl -fsSL https://raw.githubusercontent.com/DEDI1956/blackshot/main/install.sh)"
    exit 1
  fi
}

install_dependencies() {
  echo "[INFO] Menginstall dependency (git, curl, jq, net-tools)..."

  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y git curl jq net-tools
  elif command -v apt >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt update -y
    apt install -y git curl jq net-tools
  else
    echo "[ERROR] Paket manager tidak dikenali. Script ini ditujukan untuk Ubuntu/Debian (apt/apt-get)."
    exit 1
  fi
}

clone_or_update_repo() {
  if [[ -d "${INSTALL_DIR}" ]]; then
    if [[ -d "${INSTALL_DIR}/.git" ]]; then
      echo "[INFO] Repo sudah ada di ${INSTALL_DIR}. Melakukan update..."

      local current_origin
      current_origin="$(git -C "${INSTALL_DIR}" remote get-url origin 2>/dev/null || true)"
      if [[ -n "${current_origin}" && "${current_origin}" != "${REPO_URL}" ]]; then
        echo "[ERROR] Origin repo di ${INSTALL_DIR} tidak sesuai."
        echo "        Ditemukan: ${current_origin}"
        echo "        Diharapkan: ${REPO_URL}"
        echo "        Demi keamanan, installer tidak akan mengubah repo tersebut."
        exit 1
      fi

      if ! git -C "${INSTALL_DIR}" diff --quiet || ! git -C "${INSTALL_DIR}" diff --cached --quiet; then
        echo "[ERROR] Repo ${INSTALL_DIR} memiliki perubahan lokal (working tree tidak bersih)."
        echo "        Harap bersihkan perubahan terlebih dahulu sebelum update."
        exit 1
      fi

      git -C "${INSTALL_DIR}" fetch origin --prune

      if git -C "${INSTALL_DIR}" rev-parse --verify --quiet refs/remotes/origin/main >/dev/null; then
        git -C "${INSTALL_DIR}" checkout -q main 2>/dev/null || git -C "${INSTALL_DIR}" checkout -q -b main origin/main
        git -C "${INSTALL_DIR}" pull --ff-only origin main
      else
        echo "[ERROR] Branch origin/main tidak ditemukan pada repo."
        exit 1
      fi
    else
      echo "[ERROR] Direktori ${INSTALL_DIR} sudah ada tetapi bukan git repository."
      echo "        Demi keamanan, installer tidak akan menimpa isi direktori tersebut."
      exit 1
    fi
  else
    echo "[INFO] Clone repo ke ${INSTALL_DIR}..."
    mkdir -p "$(dirname "${INSTALL_DIR}")"
    git clone --branch main "${REPO_URL}" "${INSTALL_DIR}"
  fi
}

copy_menus_to_usr_bin() {
  if [[ ! -d "${SRC_BIN_DIR}" ]]; then
    echo "[ERROR] Direktori sumber menu tidak ditemukan: ${SRC_BIN_DIR}"
    exit 1
  fi

  echo "[INFO] Copy semua file menu dari ${SRC_BIN_DIR} ke ${DEST_BIN_DIR}..."
  mkdir -p "${DEST_BIN_DIR}"

  shopt -s nullglob
  local files=("${SRC_BIN_DIR}"/*)
  shopt -u nullglob

  if (( ${#files[@]} == 0 )); then
    echo "[ERROR] Tidak ada file di ${SRC_BIN_DIR}"
    exit 1
  fi

  for f in "${files[@]}"; do
    if [[ -f "${f}" ]]; then
      local basename
      basename="$(basename "${f}")"
      echo "  → Copying ${basename}"
      cp -f "${f}" "${DEST_BIN_DIR}/"
    fi
  done

  echo "[INFO] Set permission executable untuk menu yang diwajibkan..."

  local required_menus=(
    "${DEST_BIN_DIR}/menu"
    "${DEST_BIN_DIR}/ssh-menu"
    "${DEST_BIN_DIR}/vmess-menu"
    "${DEST_BIN_DIR}/vless-menu"
    "${DEST_BIN_DIR}/trojan-menu"
  )

  for menu_file in "${required_menus[@]}"; do
    if [[ ! -f "${menu_file}" ]]; then
      echo "[ERROR] File menu wajib tidak ditemukan setelah copy: ${menu_file}"
      exit 1
    fi
    chmod +x "${menu_file}"
  done

  if [[ -f "${DEST_BIN_DIR}/vpn-lib.sh" ]]; then
    chmod +x "${DEST_BIN_DIR}/vpn-lib.sh"
  fi

  if [[ -f "${DEST_BIN_DIR}/telegram-bot.sh" ]]; then
    chmod +x "${DEST_BIN_DIR}/telegram-bot.sh"
  fi
}

show_banner() {
  echo "========================================="
  echo "  BLACKSHOT VPN Panel Installer"
  echo "========================================="
  echo "  Repository: github.com/DEDI1956/blackshot"
  echo "  Install Dir: ${INSTALL_DIR}"
  echo "========================================="
  echo
}

main() {
  show_banner
  require_root
  install_dependencies
  clone_or_update_repo
  copy_menus_to_usr_bin

  echo
  echo "========================================="
  echo "[OK] Instalasi berhasil!"
  echo "========================================="
  echo
  echo "Menu yang tersedia:"
  echo "  - menu           : Menu utama"
  echo "  - ssh-menu       : Menu SSH"
  echo "  - vmess-menu     : Menu VMESS"
  echo "  - vless-menu     : Menu VLESS"
  echo "  - trojan-menu    : Menu TROJAN"
  echo
  echo "Jalankan dengan perintah: menu"
  echo "========================================="
  echo
}

main "$@"

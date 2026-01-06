#!/usr/bin/env bash
# ============================================================================
# VPN ALL-IN-ONE INSTALLER
# One-command installation with domain setup
# Author: cto.new
# ============================================================================

set -euo pipefail

# Enhanced color definitions
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

# Animation functions
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf "[%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Progress bar
show_progress() {
  local current=$1
  local total=$2
  local task=$3
  local percent=$((current * 100 / total))
  local filled=$((percent / 2))
  local empty=$((50 - filled))
  
  printf "\r${C_CYAN}Progress: [${C_GREEN}"
  printf "%${filled}s" | tr ' ' '='
  printf "%${empty}s" | tr ' ' ' '
  printf "${C_CYAN}] ${percent}%% - ${task}${C_RESET}"
}

# Print beautiful header
print_welcome_header() {
  clear
  cat <<'EOF'
 ███████╗██████╗ ██╗  ██╗ █████╗ ██████╗ ██████╗ ███████╗
 ██╔════╝██╔══██╗██║  ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝
 ███████╗██████╔╝███████║██║  ██║██║  ██║██████╔╝█████╗  
 ╚════██║██╔═══╝ ██╔══██║██║  ██║██║  ██║██╔══██╗██╔══╝  
 ███████║██║     ██║  ██║╚█████╔╝██║  ██║██║  ██║███████╗
 ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
EOF
  echo
  echo "${C_BOLD}${C_CYAN}    ███████╗██╗   ██╗███╗   ███╗███████╗██╗   ██╗████████╗ ██████╗${C_RESET}"
  echo "${C_BOLD}${C_CYAN}    ██╔════╝╚██╗ ██╔╝████╗ ████║██╔════╝██║   ██║╚══██╔══╝██╔═══██╗${C_RESET}"
  echo "${C_BOLD}${C_CYAN}    █████╗   ╚████╔╝ ██╔████╔██║███████╗██║   ██║   ██║   ██║   ██║${C_RESET}"
  echo "${C_BOLD}${C_CYAN}    ██╔══╝    ╚██╔╝  ██║╚██╔╝██║╚════██║██║   ██║   ██║   ██║   ██║${C_RESET}"
  echo "${C_BOLD}${C_CYAN}    ███████╗   ██║   ██║ ╚═╝ ██║███████║╚██████╔╝   ██║   ╚██████╔╝${C_RESET}"
  echo "${C_BOLD}${C_CYAN}    ╚══════╝   ╚═╝   ╚═╝     ╚═╝╚══════╝ ╚═════╝    ╚═╝    ╚═════╝ ${C_RESET}"
  echo
  echo "${C_BOLD}${C_YELLOW}               🔥 PREMIUM VPN INSTALLER 🔥${C_RESET}"
  echo "${C_DIM}                One Command • Full Setup • Easy Management${C_RESET}"
  echo
}

# Check root access
require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo
    echo "${C_RED}${C_BOLD}[ERROR]${C_RESET} Script ini harus dijalankan sebagai root!"
    echo "${C_YELLOW}Jalankan:${C_RESET} sudo bash $0"
    echo
    exit 1
  fi
}

# OS compatibility check
check_os() {
  echo "${C_BLUE}🔍 Checking system compatibility...${C_RESET}"
  
  if [[ ! -f /etc/os-release ]]; then
    echo "${C_RED}[ERROR]${C_RESET} OS tidak didukung!"
    exit 1
  fi
  
  source /etc/os-release
  
  case "$ID" in
    ubuntu)
      if [[ "$VERSION_ID" != "20.04" && "$VERSION_ID" != "22.04" && "$VERSION_ID" != "24.04" ]]; then
        echo "${C_YELLOW}[WARNING]${C_RESET} Ubuntu $VERSION_ID belum teruji"
        echo "${C_YELLOW}[WARNING]${C_RESET} Direkomendasikan Ubuntu 20.04/22.04"
        read -r -p "Lanjutkan? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          exit 1
        fi
      fi
      ;;
    debian)
      if [[ "${VERSION_ID}" != "11" && "${VERSION_ID}" != "12" ]]; then
        echo "${C_RED}[ERROR]${C_RESET} Debian ${VERSION_ID} tidak didukung!"
        exit 1
      fi
      ;;
    *)
      echo "${C_RED}[ERROR]${C_RESET} OS tidak didukung! Gunakan Ubuntu/Debian"
      exit 1
      ;;
  esac
  
  echo "${C_GREEN}[OK]${C_RESET} OS ${PRETTY_NAME} kompatibel"
}

# Network and DNS check
check_network() {
  echo "${C_BLUE}🌐 Checking network connectivity...${C_RESET}"
  
  if ! ping -c 1 google.com &>/dev/null; then
    echo "${C_YELLOW}[WARNING]${C_RESET} Tidak ada koneksi internet"
    read -r -p "Lanjutkan instalasi offline? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  else
    echo "${C_GREEN}[OK]${C_RESET} Internet connectivity: ${C_GREEN}Available${C_RESET}"
  fi
}

# Domain validation
validate_domain() {
  local domain="$1"
  local domain_regex='^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.([a-zA-Z]{2,})$'
  
  if [[ ! $domain =~ $domain_regex ]]; then
    return 1
  fi
  
  # Check if domain resolves
  if ! nslookup "$domain" &>/dev/null; then
    echo "${C_YELLOW}[WARNING]${C_RESET} Domain tidak bisa diselesaikan DNS"
    return 1
  fi
  
  return 0
}

# Get domain input with validation
get_domain() {
  echo
  echo "${C_BOLD}${C_YELLOW}🌐 DOMAIN SETUP${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  echo "${C_WHITE}• Masukkan domain yang akan digunakan untuk VPN${C_RESET}"
  echo "${C_WHITE}• Pastikan domain sudah menunjuk ke IP VPS ini${C_RESET}"
  echo "${C_WHITE}• SSL certificate akan otomatis dibuat untuk domain${C_RESET}"
  echo
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  
  while true; do
    echo -n "${C_GREEN}🌍 Masukkan domain Anda: ${C_RESET}"
    read -r domain
    
    if [[ -z "$domain" ]]; then
      echo "${C_YELLOW}[WARNING]${C_RESET} Domain tidak boleh kosong!"
      continue
    fi
    
    if validate_domain "$domain"; then
      echo "${C_GREEN}[OK]${C_RESET} Domain valid: ${C_GREEN}${domain}${C_RESET}"
      
      # Get current IP
      local current_ip
      current_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null)
      
      echo
      echo "${C_BLUE}📊 Informasi Domain:${C_RESET}"
      echo "   Domain      : ${C_CYAN}${domain}${C_RESET}"
      echo "   VPS IP      : ${C_CYAN}${current_ip:-Unknown}${C_RESET}"
      echo
      echo "${C_YELLOW}⚠️  Pastikan domain ${domain} sudah menunjuk ke IP ${current_ip:-Unknown}!${C_RESET}"
      echo
      read -r -p "Lanjutkan instalasi? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        break
      fi
    else
      echo "${C_RED}[ERROR]${C_RESET} Format domain tidak valid!"
      echo "${C_YELLOW}Contoh:${C_RESET} example.com, vpn.example.com"
    fi
  done
}

# Install system dependencies
install_dependencies() {
  echo
  echo "${C_BOLD}${C_MAGENTA}📦 INSTALLING DEPENDENCIES${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  
  local total_steps=8
  local current_step=0
  
  # Update package list
  ((current_step++))
  show_progress $current_step $total_steps "Updating package list..."
  export DEBIAN_FRONTEND=noninteractive
  
  if [[ -f /etc/debian_version ]]; then
    apt-get update -y >/dev/null 2>&1 &
    spinner $!
    wait $!
  fi
  
  # Install core packages
  ((current_step++))
  show_progress $current_step $total_steps "Installing core packages..."
  apt-get install -y curl wget git jq net-tools htop unzip software-properties-common dnsutils >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install Python and pip
  ((current_step++))
  show_progress $current_step $total_steps "Installing Python..."
  apt-get install -y python3 python3-pip python3-venv >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install Node.js and npm
  ((current_step++))
  show_progress $current_step $total_steps "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - >/dev/null 2>&1
  apt-get install -y nodejs >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install Nginx
  ((current_step++))
  show_progress $current_step $total_steps "Installing Nginx..."
  apt-get install -y nginx >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install Certbot
  ((current_step++))
  show_progress $current_step $total_steps "Installing Certbot..."
  apt-get install -y certbot python3-certbot-nginx >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install Xray core
  ((current_step++))
  show_progress $current_step $total_steps "Installing Xray core..."
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  # Install additional utilities
  ((current_step++))
  show_progress $current_step $total_steps "Installing additional utilities..."
  apt-get install -y ufw fail2ban screen tmux nano vim htop iotop >/dev/null 2>&1 &
  spinner $!
  wait $!
  
  echo
  echo "${C_GREEN}[SUCCESS]${C_RESET} Semua dependencies berhasil diinstall!"
  echo
}

# Configure system
configure_system() {
  echo "${C_BOLD}${C_YELLOW}⚙️  CONFIGURING SYSTEM${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  
  local total_steps=6
  local current_step=0
  
  # Configure firewall
  ((current_step++))
  show_progress $current_step $total_steps "Configuring UFW firewall..."
  ufw --force reset >/dev/null 2>&1
  ufw default deny incoming >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  ufw allow ssh >/dev/null 2>&1
  ufw allow 80/tcp >/dev/null 2>&1
  ufw allow 443/tcp >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} UFW configured"
  
  # Configure fail2ban
  ((current_step++))
  show_progress $current_step $total_steps "Configuring fail2ban..."
  systemctl enable fail2ban >/dev/null 2>&1
  systemctl start fail2ban >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} fail2ban configured"
  
  # Configure Nginx
  ((current_step++))
  show_progress $current_step $total_steps "Configuring Nginx..."
  systemctl enable nginx >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} Nginx configured"
  
  # Configure Xray
  ((current_step++))
  show_progress $current_step $total_steps "Configuring Xray..."
  systemctl enable xray >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} Xray configured"
  
  # Optimize system
  ((current_step++))
  show_progress $current_step $total_steps "Optimizing system..."
  echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
  echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
  echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
  echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
  sysctl -p >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} System optimized"
  
  # Create directories
  ((current_step++))
  show_progress $current_step $total_steps "Creating directories..."
  mkdir -p /etc/xray
  mkdir -p /var/log/xray
  mkdir -p /usr/local/etc/xray
  echo "${C_GREEN}[OK]${C_RESET} Directories created"
  
  echo
  echo "${C_GREEN}[SUCCESS]${C_RESET} System configuration completed!"
  echo
}

# Setup SSL certificate
setup_ssl() {
  echo "${C_BOLD}${C_YELLOW}🔒 SETTING UP SSL CERTIFICATE${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  
  echo "${C_BLUE}🌐 Configuring Nginx for domain: ${C_CYAN}${domain}${C_RESET}"
  
  # Create Nginx config
  cat > /etc/nginx/sites-available/vpn <<EOF
server {
    listen 80;
    server_name ${domain};
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
EOF

  # Enable site
  ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/
  rm -f /etc/nginx/sites-enabled/default
  
  # Test and reload Nginx
  nginx -t >/dev/null 2>&1
  systemctl reload nginx
  
  echo "${C_BLUE}🔐 Obtaining SSL certificate...${C_RESET}"
  echo "${C_YELLOW}Harap tunggu, proses certificate generation memerlukan waktu...${C_RESET}"
  echo
  
  # Get SSL certificate
  if certbot --nginx -d "${domain}" --non-interactive --agree-tos --email admin@${domain} --redirect; then
    echo "${C_GREEN}[SUCCESS]${C_RESET} SSL certificate berhasil dibuat!"
    echo "${C_GREEN}[INFO]${C_RESET} Certificate akan otomatis diperbarui"
  else
    echo "${C_YELLOW}[WARNING]${C_RESET} Gagal mendapatkan SSL certificate"
    echo "${C_YELLOW}[WARNING]${C_RESET} SSL akan dikonfigurasi nanti"
  fi
  
  echo
}

# Install VPN management interface
install_vpn_interface() {
  echo "${C_BOLD}${C_YELLOW}🎛️  INSTALLING VPN MANAGEMENT INTERFACE${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  
  local total_steps=4
  local current_step=0
  
  # Copy VPN files
  ((current_step++))
  show_progress $current_step $total_steps "Copying VPN interface files..."
  if [[ -d "/home/engine/project/usr/bin" ]]; then
    cp -r /home/engine/project/usr/bin/* /usr/bin/
    chmod +x /usr/bin/menu /usr/bin/*-menu 2>/dev/null || true
  fi
  
  # Copy main script
  ((current_step++))
  show_progress $current_step $total_steps "Installing main panel..."
  if [[ -f "/home/engine/project/vpn-aio-panel.sh" ]]; then
    cp /home/engine/project/vpn-aio-panel.sh /usr/local/bin/vpn-panel
    chmod +x /usr/local/bin/vpn-panel
  fi
  
  # Create symlinks
  ((current_step++))
  show_progress $current_step $total_steps "Creating command shortcuts..."
  ln -sf /usr/local/bin/vpn-panel /usr/bin/vpn 2>/dev/null || true
  ln -sf /usr/bin/menu /usr/bin/vpn-menu 2>/dev/null || true
  
  # Configure Telegram bot (optional)
  ((current_step++))
  show_progress $current_step $total_steps "Setting up Telegram bot..."
  mkdir -p /etc/vpn-panel
  cat > /etc/vpn-panel/telegram.env <<EOF
BOT_TOKEN=
CHAT_ID=
EOF
  
  echo "${C_GREEN}[SUCCESS]${C_RESET} VPN management interface installed!"
  echo
}

# Final configuration
finalize_installation() {
  echo "${C_BOLD}${C_YELLOW}🎉 FINALIZING INSTALLATION${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  
  local total_steps=5
  local current_step=0
  
  # Save domain configuration
  ((current_step++))
  show_progress $current_step $total_steps "Saving domain configuration..."
  echo "${domain}" > /etc/xray/domain
  echo "${domain}" > /etc/vpn-panel/domain
  echo "${C_GREEN}[OK]${C_RESET} Domain configuration saved"
  
  # Start services
  ((current_step++))
  show_progress $current_step $total_steps "Starting services..."
  systemctl start nginx
  systemctl start xray
  systemctl enable nginx
  systemctl enable xray
  ufw --force enable >/dev/null 2>&1
  echo "${C_GREEN}[OK]${C_RESET} Services started"
  
  # Generate default configuration
  ((current_step++))
  show_progress $current_step $total_steps "Generating default configuration..."
  create_default_config
  echo "${C_GREEN}[OK]${C_RESET} Default configuration created"
  
  # Create backup
  ((current_step++))
  show_progress $current_step $total_steps "Creating initial backup..."
  mkdir -p /root/backup
  tar -czf "/root/backup/vpn-backup-$(date +%Y%m%d-%H%M%S).tar.gz" /etc/xray /etc/vpn-panel >/dev/null 2>&1 || true
  echo "${C_GREEN}[OK]${C_RESET} Backup created"
  
  # Display completion message
  ((current_step++))
  show_progress $current_step $total_steps "Installation complete!"
  
  echo
}

# Create default Xray configuration
create_default_config() {
  cat > /etc/xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
}

# Display success message
show_completion_message() {
  echo
  echo "${C_GREEN}${C_BOLD}"
  cat <<'EOF'
 ██████╗ ██████╗ ███╗   ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗
 ██╔══██╗██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██║   ██║██╔════╝
 ██████╔╝██████╔╝██╔██╗ ██║██║   ██║██║  ██║██║   ██║███████╗
 ██╔═══╝ ██╔══██╗██║╚██╗██║██║   ██║██║  ██║██║   ██║╚════██║
 ██║     ██║  ██║██║ ╚████║╚██████╔╝██████╔╝╚██████╔╝███████║
 ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝
EOF
  echo "${C_RESET}"
  echo
  echo "${C_BOLD}${C_GREEN}🎊 INSTALLASI BERHASIL DISELESAIKAN! 🎊${C_RESET}"
  echo
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  echo "${C_YELLOW}📋 INFORMASI INSTALASI:${C_RESET}"
  echo "   Domain        : ${C_GREEN}${domain}${C_RESET}"
  echo "   VPS IP        : ${C_GREEN}$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")${C_RESET}"
  echo "   Install Date  : ${C_GREEN}$(date)${C_RESET}"
  echo
  echo "${C_YELLOW}🚀 CARA MENGGUNAKAN:${C_RESET}"
  echo "   • ${C_CYAN}menu${C_RESET}           - Buka menu utama VPN"
  echo "   • ${C_CYAN}vpn-panel${C_RESET}     - Buka panel lengkap"
  echo "   • ${C_CYAN}vpn-menu${C_RESET}     - Alias untuk menu utama"
  echo
  echo "${C_YELLOW}🔧 FITUR YANG TERSEDIA:${C_RESET}"
  echo "   ✓ SSH User Management"
  echo "   ✓ VMess/VLess/Trojan Accounts"
  echo "   ✓ SSL Certificate Management"
  echo "   ✓ Backup & Restore"
  echo "   ✓ Telegram Bot Integration"
  echo "   ✓ System Monitoring"
  echo "   ✓ Speedtest Tools"
  echo
  echo "${C_YELLOW}⚡ QUICK START:${C_RESET}"
  echo "   ${C_GREEN}menu${C_RESET}           - Mulai manajemen VPN"
  echo "   ${C_GREEN}menu ssh${C_RESET}      - Kelola SSH users"
  echo "   ${C_GREEN}menu vmess${C_RES}     - Buat VMess accounts"
  echo
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  echo "${C_BOLD}${C_MAGENTA}💡 TIPS:${C_RESET}"
  echo "   • Gunakan '${C_CYAN}menu${C_RESET}' untuk akses semua fitur"
  echo "   • Backup otomatis tersedia di '/root/backup/'"
  echo "   • SSL certificate akan diperbarui otomatis"
  echo "   • Check log dengan '${C_CYAN}journalctl -u xray${C_RESET}'"
  echo
  echo "${C_BOLD}${C_GREEN}🎯 SELAMAT! VPN PANEL ANDA SIAP DIGUNAKAN! 🎯${C_RESET}"
  echo
}

# Main installation function
main() {
  print_welcome_header
  
  echo "${C_YELLOW}🔥 Selamat datang di VPN All-in-One Installer!${C_RESET}"
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  echo "${C_WHITE}Installer ini akan:${C_RESET}"
  echo "   • ${C_GREEN}✓${C_RESET} Install semua dependency yang diperlukan"
  echo "   • ${C_GREEN}✓${C_RESET} Setup SSL certificate untuk domain Anda"
  echo "   • ${C_GREEN}✓${C_RESET} Konfigurasi Nginx, Xray, dan firewall"
  echo "   • ${C_GREEN}✓${C_RESET} Install interface manajemen VPN"
  echo "   • ${C_GREEN}✓${C_RESET} Setup backup dan monitoring"
  echo "   • ${C_GREEN}✓${C_RESET} Optimasi sistem untuk performa terbaik"
  echo
  echo "${C_YELLOW}⚠️  PERHATIAN:${C_RESET} Installer ini memerlukan akses root dan koneksi internet"
  echo
  
  read -r -p "Lanjutkan instalasi? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "${C_YELLOW}[INFO]${C_RESET} Instalasi dibatalkan."
    exit 0
  fi
  
  echo
  echo "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  
  require_root
  check_os
  check_network
  get_domain
  
  install_dependencies
  configure_system
  setup_ssl
  install_vpn_interface
  finalize_installation
  show_completion_message
}

# Handle interruption
trap 'echo; echo; echo "${C_YELLOW}[INFO]${C_RESET} Instalasi dibatalkan oleh user."; exit 130' INT

# Run main function
main "$@"
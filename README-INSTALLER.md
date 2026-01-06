# 🔥 VPN ALL-IN-ONE INSTALLER

## 📖 Deskripsi

VPN All-in-One Installer adalah solusi lengkap untuk instalasi dan manajemen VPN server dengan satu perintah. Installer ini dirancang untuk memberikan pengalaman yang mudah, otomatis, dan profesional.

## ✨ Fitur Unggulan

### 🎯 Instalasi Otomatis
- **One-Command Install**: Install lengkap dengan satu perintah
- **Domain-Based Setup**: Setup berdasarkan domain yang Anda berikan
- **Auto SSL**: Sertifikat SSL otomatis dengan Let's Encrypt
- **Auto Renewal**: Pembaruan sertifikat SSL otomatis
- **Dependency Management**: Install semua dependency yang diperlukan

### 🎛️ Interface Manajemen
- **TUI Management Panel**: Interface yang mudah dan user-friendly
- **Real-time Monitoring**: Monitor sistem secara real-time
- **Multi-Protocol Support**: VMess, VLess, Trojan, SSH, dll
- **Service Management**: Kelola layanan dengan mudah

### 🛡️ Keamanan & Backup
- **Firewall Setup**: UFW firewall otomatis
- **Fail2ban Protection**: Proteksi brute force
- **Backup & Restore**: Backup dan restore konfigurasi
- **SSL Certificate Management**: Manajemen sertifikat SSL

### 🔧 Tools & Monitoring
- **Telegram Bot Integration**: Integrasi bot Telegram
- **Speedtest Tools**: Tools speedtest built-in
- **System Monitoring**: Monitor resource usage
- **Log Management**: Manajemen log yang baik

## 🚀 Cara Instalasi

### Metode 1: Direct Install
```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-vpn.sh | sudo bash
```

### Metode 2: Manual Download
```bash
# Download installer
wget -O install-vpn.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-vpn.sh

# Jalankan installer
sudo bash install-vpn.sh
```

### Metode 3: From Repository
```bash
# Clone repository
git clone https://github.com/your-repo/vpn-installer.git
cd vpn-installer

# Jalankan installer
sudo bash install-vpn.sh
```

## 📋 Persyaratan Sistem

### Sistem Operasi
- ✅ Ubuntu 20.04 LTS
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 11
- ✅ Debian 12

### Spesifikasi Minimum
- **RAM**: 512MB
- **Storage**: 5GB free space
- **Network**: Koneksi internet stabil
- **Access**: Root access

### Network Requirements
- Port 22 (SSH) - open
- Port 80 (HTTP) - open
- Port 443 (HTTPS) - open

### Domain Requirements
- Domain yang menunjuk ke IP VPS
- DNS propagation selesai
- SSL certificate akan dibuat otomatis

## 🔧 Proses Instalasi

### 1. Welcome Screen
Installer menampilkan welcome screen yang menarik dengan ASCII art dan informasi fitur.

### 2. Domain Setup
- Masukkan domain Anda
- Validasi format domain
- Check DNS resolution
- Konfirmasi dengan user

### 3. System Check
- OS compatibility check
- Network connectivity test
- Root access verification

### 4. Dependency Installation
- Update package list
- Install core packages
- Install Python/Node.js
- Install Nginx & Certbot
- Install Xray core
- Install additional utilities

### 5. System Configuration
- Configure UFW firewall
- Setup fail2ban
- Optimize system parameters
- Create necessary directories

### 6. SSL Setup
- Configure Nginx for domain
- Obtain SSL certificate
- Setup auto-renewal

### 7. VPN Interface Installation
- Copy VPN management files
- Create command shortcuts
- Setup Telegram bot configuration

### 8. Finalization
- Save domain configuration
- Start services
- Generate default config
- Create initial backup

## 🎮 Cara Penggunaan

Setelah instalasi selesai, gunakan perintah berikut:

### Menu Utama
```bash
menu                    # Buka menu utama VPN
vpn-panel              # Buka panel lengkap
vpn-menu               # Alias untuk menu utama
```

### Management Commands
```bash
menu ssh               # Kelola SSH users
menu vmess             # Buat VMess accounts
menu vless             # Buat VLess accounts
menu trojan            # Buat Trojan accounts
menu backup            # Backup & restore
menu speedtest         # Jalankan speedtest
```

### Monitoring
```bash
journalctl -u xray     # Lihat log Xray
systemctl status nginx # Status Nginx
ufw status            # Status firewall
```

## 📊 Fitur Menu

### MANAGEMENT MENUS
- **SSH MENU**: Kelola user SSH (add, delete, renew, list)
- **VMESS MENU**: Kelola akun VMess
- **VLESS MENU**: Kelola akun VLess
- **TROJAN MENU**: Kelola akun Trojan
- **AKUN NOOBZVPN**: Kelola NoobzVPN
- **SS-LIBEV**: Kelola Shadowsocks
- **INSTALL UDP**: Install UDP custom

### TOOLS & UTILITIES
- **BACKUP / RESTORE**: Backup dan restore konfigurasi
- **GOTO X RAM**: Optimasi RAM
- **RESTART ALL**: Restart semua layanan
- **TELE BOT**: Konfigurasi bot Telegram
- **UPDATE MENU**: Update menu
- **RUNNING SERVICE**: Lihat service yang berjalan
- **INFO PORT**: Informasi port
- **MENU BOT**: Bot management
- **SPEEDTEST**: Tools speedtest

### DOMAIN & SSL
- **CHANGE DOMAIN**: Ubah domain
- **RENEW SSL CERT**: Perbarui sertifikat SSL
- **VALIDATE DOMAIN**: Validasi domain
- **FIX CERT DOMAIN**: Perbaiki masalah sertifikat

### CUSTOMIZATION
- **CHANGE BANNER**: Ubah banner
- **RESTART BANNER**: Restart banner

## 🛠️ Troubleshooting

### Domain tidak bisa diselesaikan DNS
```bash
# Check DNS resolution
nslookup your-domain.com

# Check if domain points to VPS IP
dig your-domain.com
```

### SSL certificate gagal
```bash
# Check Nginx configuration
nginx -t

# Check domain DNS
curl -I http://your-domain.com

# Manual certificate generation
certbot --nginx -d your-domain.com
```

### Service tidak berjalan
```bash
# Check Xray status
systemctl status xray

# Restart Xray
systemctl restart xray

# Check logs
journalctl -u xray -f
```

### Menu tidak berfungsi
```bash
# Check file permissions
ls -la /usr/bin/menu
chmod +x /usr/bin/menu

# Check library
source /usr/bin/vpn-lib.sh
```

## 📁 Struktur File

### Setelah Instalasi
```
/etc/xray/                    # Xray configuration
/etc/xray/domain             # Domain configuration
/etc/vpn-panel/              # VPN panel config
/etc/nginx/sites-available/  # Nginx configuration
/var/log/xray/              # Xray logs
/root/backup/               # Backup files
/usr/bin/menu               # Main menu
/usr/bin/*-menu             # Individual menus
/usr/bin/vpn-lib.sh         # Shared library
/usr/local/bin/vpn-panel    # Main panel
```

## 🔄 Backup & Restore

### Backup Otomatis
- Backup dibuat otomatis setiap selesai instalasi
- Disimpan di `/root/backup/vpn-backup-TIMESTAMP.tar.gz`

### Backup Manual
```bash
# Manual backup
menu backup

# atau via command line
tar -czf /root/backup/manual-backup-$(date +%Y%m%d-%H%M%S).tar.gz /etc/xray /etc/vpn-panel
```

### Restore
```bash
# Restore dari backup
menu backup

# atau manual
tar -xzf /root/backup/vpn-backup-20240106-120000.tar.gz -C /
```

## 🤖 Telegram Bot

### Setup Bot
1. Buat bot melalui @BotFather
2. Dapatkan BOT_TOKEN
3. Dapatkan CHAT_ID Anda
4. Konfigurasi di menu `menu bot`

### Commands Bot
- `/backup` - Backup konfigurasi
- `/restore` - Restore dari file
- `/status` - Status layanan
- `/speedtest` - Jalankan speedtest

## 🔐 Keamanan

### Firewall Rules
```bash
# Check UFW status
ufw status

# Manual rules
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
```

### Fail2ban
```bash
# Check fail2ban
systemctl status fail2ban

# View banned IPs
fail2ban-client status sshd
```

### SSL Security
- Auto-renewal setiap 3 bulan
- Force HTTPS redirect
- Modern TLS configurations

## 📈 Monitoring

### System Resources
```bash
# RAM usage
free -h

# Disk usage
df -h

# CPU usage
htop

# Network connections
netstat -tuln
```

### Service Monitoring
```bash
# Check all VPN services
systemctl list-units --type=service | grep -E "(xray|nginx|ssh)"

# Real-time logs
journalctl -u xray -f
```

## 🔄 Updates

### Update Installer
```bash
# Download latest installer
wget -O install-vpn.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-vpn.sh

# Run update
sudo bash install-vpn.sh
```

### Update Menu
```bash
# Via menu
menu update

# Manual
cd /opt/blackshot && git pull
```

## 📞 Support

### Log Files
- `/var/log/xray/access.log` - Xray access log
- `/var/log/xray/error.log` - Xray error log
- `journalctl -u xray` - Systemd log Xray
- `journalctl -u nginx` - Systemd log Nginx

### Common Issues
1. **Domain tidak resolve**: Pastikan DNS propagation selesai
2. **SSL gagal**: Check apakah port 80/443 terbuka
3. **Menu error**: Check permissions dan library
4. **Service down**: Check logs dan restart service

## 📄 License

MIT License - Lihat file LICENSE untuk detail.

## 🤝 Contributing

Kontribusi sangat diterima! Silakan buat pull request atau issue.

## ⚠️ Disclaimer

Script ini untuk tujuan edukasi dan penggunaan legal. Pengguna bertanggung jawab atas penggunaan yang sesuai hukum setempat.

---

**🔥 Happy VPN-ing! 🔥**
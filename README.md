# VPN All-in-One TUI Panel

**Bash TUI Panel** untuk manajemen VPN Server (Ubuntu 20.04 / 22.04)

## 🌟 Features

- ✅ **Modular Menu Structure** - Script terpisah dengan bash sourcing
- ✅ **Dashboard Monitoring** - Real-time system & service status
- ✅ **SSH Management** - Add, delete, renew, list users
- ✅ **XRAY Support** - VMESS, VLESS, TROJAN protocols
- ✅ **Service Control** - Start, stop, restart all services
- ✅ **Backup/Restore** - Configuration backup & restore
- ✅ **Domain Management** - Change domain & SSL certificates
- ✅ **Speedtest** - Built-in network speed testing
- ✅ **Multi-Protocol** - SSH, XRAY, NOOBZVPN, UDP Custom, Shadowsocks

## 📦 Installation

### Quick Install

```bash
# Clone repository
git clone <repository-url>
cd vpn-aio-panel

# Install modular menus
sudo bash install-menus.sh

# Or use the all-in-one script
sudo bash vpn-aio-panel.sh
```

### Manual Install

```bash
# Copy files to /usr/bin
sudo cp usr/bin/vpn-lib.sh /usr/bin/
sudo cp usr/bin/menu /usr/bin/
sudo cp usr/bin/ssh-menu /usr/bin/
sudo cp usr/bin/vmess-menu /usr/bin/
sudo cp usr/bin/vless-menu /usr/bin/
sudo cp usr/bin/trojan-menu /usr/bin/

# Set permissions
sudo chmod +x /usr/bin/{vpn-lib.sh,menu,ssh-menu,vmess-menu,vless-menu,trojan-menu}
```

## 🚀 Usage

### Main Menu

```bash
sudo menu
```

### Individual Menus

```bash
sudo ssh-menu      # SSH account management
sudo vmess-menu    # VMESS protocol menu
sudo vless-menu    # VLESS protocol menu
sudo trojan-menu   # TROJAN protocol menu
```

### All-in-One Version

```bash
sudo bash vpn-aio-panel.sh
```

## 📁 File Structure

```
.
├── vpn-aio-panel.sh          # All-in-one script (original)
├── usr/bin/
│   ├── vpn-lib.sh            # Shared library functions
│   ├── menu                  # Main menu
│   ├── ssh-menu              # SSH management
│   ├── vmess-menu            # VMESS management
│   ├── vless-menu            # VLESS management
│   └── trojan-menu           # TROJAN management
├── install-menus.sh          # Installer script
├── uninstall-menus.sh        # Uninstaller script
├── test-menus.sh             # Test suite
├── README.md                 # This file
├── README-MENUS.md           # Modular structure documentation
├── CHANGELOG.md              # Version history
└── .gitignore                # Git ignore rules
```

## 🎯 Menu Structure

### Main Menu (1-21)
1. **SSH MENU** - Manage SSH users
2. **VMESS MENU** - Manage VMESS accounts
3. **VLESS MENU** - Manage VLESS accounts
4. **TROJAN MENU** - Manage TROJAN accounts
5. **AKUN NOOBZVPN** - Manage NOOBZVPN accounts
6. **SS - LIBEV** - Shadowsocks libev control
7. **INSTALL UDP** - UDP Custom installation
8. **BACKUP / RESTORE** - Configuration backup
9. **GOTO X RAM** - RAM optimization
10. **RESTART ALL** - Restart all services
11. **TELE BOT** - Telegram bot integration
12. **UPDATE MENU** - Update menu scripts
13. **RUNNING SERVICE** - View service status
14. **INFO PORT** - View listening ports
15. **MENU BOT** - Bot management
16. **CHANGE DOMAIN** - Update domain
17. **FIX CERT DOMAIN** - Fix SSL certificates
18. **CHANGE BANNER** - Update SSH banner
19. **RESTART BANNER** - Restart SSH services
20. **SPEEDTEST** - Network speed test
21. **EKSTRAK MENU** - Extract additional menus

### SSH Menu
1. Add SSH User
2. Delete SSH User
3. Renew SSH User (Extend Expiry)
4. List SSH Users
5. Show Logged-in Users (who)

## 🔧 Requirements

- **OS**: Ubuntu 20.04 / 22.04
- **Shell**: Bash 4.0+
- **Privileges**: Root access required
- **Tools**: systemctl, awk, sed, grep, tar
- **Optional**: jq (for better XRAY account parsing)

## 🎨 Dashboard Features

The dashboard displays:
- **System Information**
  - OS version
  - CPU cores
  - RAM usage
  - Load average
  - Uptime
  - Public IP
  - Domain

- **Account Information**
  - SSH users count
  - VMESS accounts (WS / gRPC)
  - VLESS accounts (WS / gRPC)
  - TROJAN accounts (WS / gRPC)
  - Shadowsocks accounts

- **Service Status**
  - SSH, XRAY, NGINX
  - HAPROXY, DROPBEAR, UDP Custom
  - NOOBZVPN, WS-ePro

## 🛠️ Development

### Adding New Menu

1. Create new file in `usr/bin/`
2. Source the library:
   ```bash
   source /usr/bin/vpn-lib.sh
   ```
3. Implement your menu function
4. Add `require_root` check
5. Make executable: `chmod +x`

### Example Template

```bash
#!/usr/bin/env bash
source /usr/bin/vpn-lib.sh

my_menu() {
  print_header
  render_dashboard
  # Your code here
}

main() {
  require_root
  my_menu
}

main "$@"
```

## 🧪 Testing

Run the test suite:

```bash
bash test-menus.sh
```

Tests include:
- Syntax validation
- File existence checks
- Executable permissions
- Library sourcing
- Function availability

## 📝 Configuration

Default config locations:
- XRAY: `/etc/xray/config.json`
- Domain: `/etc/xray/domain` or `/etc/v2ray/domain`
- SSH: `/etc/ssh/sshd_config`
- NGINX: `/etc/nginx/`
- HAPROXY: `/etc/haproxy/`

## 🔄 Backup & Restore

Backup includes:
- `/etc/xray`
- `/etc/nginx`
- `/etc/haproxy`
- `/etc/ssh`
- `/etc/dropbear`
- `/etc/letsencrypt`
- `/var/www`

Backup location: `/root/vpn-backup-YYYYMMDD-HHMMSS.tar.gz`

## 🗑️ Uninstall

```bash
sudo bash uninstall-menus.sh
```

This removes all menu scripts from `/usr/bin/`

## 📚 Documentation

- [README-MENUS.md](README-MENUS.md) - Detailed modular structure guide
- [CHANGELOG.md](CHANGELOG.md) - Version history and changes

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes with `test-menus.sh`
4. Submit a pull request

## ⚠️ Important Notes

- **Root Required**: All scripts must run as root
- **Safety**: Uses `set -euo pipefail` for error handling
- **Compatibility**: Works with various VPN installer scripts
- **Placeholders**: Some menus are placeholders for custom implementation

## 🔐 Security

- Runs with root privileges (required for service management)
- Password input uses `-s` flag (silent mode)
- Config file permissions should be properly set
- Backup files contain sensitive data - keep secure

## 📄 License

This project is provided as-is for VPN server management.

## 🆘 Troubleshooting

### Library not found
```bash
ls -la /usr/bin/vpn-lib.sh
sudo chmod +x /usr/bin/vpn-lib.sh
```

### Menu not executable
```bash
sudo chmod +x /usr/bin/menu
sudo chmod +x /usr/bin/ssh-menu
# ... etc
```

### Must run as root
```bash
sudo menu
# or
sudo ssh-menu
```

## 📞 Support

For issues and questions:
1. Check [README-MENUS.md](README-MENUS.md) for detailed docs
2. Review [CHANGELOG.md](CHANGELOG.md) for version info
3. Run `test-menus.sh` to verify installation
4. Check service status with menu option 13

---

**Version**: 2.0.0  
**Last Updated**: 2024-01-06  
**Platform**: Ubuntu 20.04 / 22.04  
**Shell**: Bash

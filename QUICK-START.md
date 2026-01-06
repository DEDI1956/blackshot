# Quick Start Guide

## 🚀 Installation (1 minute)

```bash
# Install all menus to /usr/bin
sudo bash install-menus.sh
```

## 📖 Basic Usage

### Option 1: Main Menu (Recommended for beginners)
```bash
sudo menu
```
- Shows dashboard with system info
- Navigate through numbered options (1-21)
- Type number and press Enter

### Option 2: Direct Menu Access (Advanced users)
```bash
sudo ssh-menu       # SSH account management
sudo vmess-menu     # VMESS protocol
sudo vless-menu     # VLESS protocol
sudo trojan-menu    # TROJAN protocol
```

## 🎯 Common Tasks

### SSH User Management

**Add new SSH user:**
```bash
sudo menu
→ Select [01] SSH MENU
→ Select [1] Add SSH User
→ Enter username, password, and expiry days
```

**Delete SSH user:**
```bash
sudo ssh-menu       # Direct access
→ Select [2] Delete SSH User
→ Enter username
```

**List all SSH users:**
```bash
sudo ssh-menu
→ Select [4] List SSH Users
```

### Service Management

**View all service status:**
```bash
sudo menu
→ Select [13] RUNNING SERVICE
```

**Restart all services:**
```bash
sudo menu
→ Select [10] RESTART ALL
→ Confirm with 'y'
```

### Backup & Restore

**Create backup:**
```bash
sudo menu
→ Select [08] BACKUP / RESTORE
→ Select [1] Create Backup
# Backup saved to /root/vpn-backup-TIMESTAMP.tar.gz
```

**Restore backup:**
```bash
sudo menu
→ Select [08] BACKUP / RESTORE
→ Select [2] Restore Backup
→ Enter backup file path
```

### Domain Management

**Change domain:**
```bash
sudo menu
→ Select [16] CHANGE DOMAIN
→ Enter new domain name
```

**Fix SSL certificate:**
```bash
sudo menu
→ Select [17] FIX CERT DOMAIN
→ Follow instructions
```

### Network Testing

**Run speedtest:**
```bash
sudo menu
→ Select [20] SPEEDTEST
# Auto-install speedtest-cli if needed
```

**View listening ports:**
```bash
sudo menu
→ Select [14] INFO PORT
```

## 💡 Pro Tips

### 1. Dashboard Information
Every menu shows real-time dashboard with:
- System resources (CPU, RAM, Load)
- Service status (SSH, XRAY, NGINX, etc)
- Account counts (SSH users, XRAY accounts)

### 2. Navigation
- Type `0` or `00` to go back/exit
- Press `CTRL+C` to exit anytime
- Press `ENTER` after viewing results

### 3. Direct Commands
```bash
# Quick SSH user list
sudo ssh-menu   # Then press 4 → Enter → Enter

# Quick service restart
sudo menu       # Then press 10 → y → Enter

# Quick backup
sudo menu       # Then press 8 → 1 → Enter
```

### 4. Multiple Sessions
You can run multiple menu instances:
```bash
# Terminal 1
sudo ssh-menu

# Terminal 2
sudo menu

# Terminal 3
sudo vmess-menu
```

### 5. Script Location
After installation, scripts are in `/usr/bin/`:
- Can run from any directory
- Available system-wide
- No need to specify full path

## 🔍 Checking Installation

**Verify all files installed:**
```bash
bash test-menus.sh
```

**Check individual files:**
```bash
which menu          # Should show: /usr/bin/menu
which ssh-menu      # Should show: /usr/bin/ssh-menu
ls -la /usr/bin/vpn-lib.sh
```

## 🛠️ Troubleshooting

### Command not found
```bash
# Re-run installer
sudo bash install-menus.sh
```

### Permission denied
```bash
# Add execute permission
sudo chmod +x /usr/bin/menu
sudo chmod +x /usr/bin/ssh-menu
sudo chmod +x /usr/bin/vmess-menu
sudo chmod +x /usr/bin/vless-menu
sudo chmod +x /usr/bin/trojan-menu
sudo chmod +x /usr/bin/vpn-lib.sh
```

### Library error
```bash
# Check library exists
ls -la /usr/bin/vpn-lib.sh

# Reinstall if missing
sudo bash install-menus.sh
```

### Must run as root
```bash
# Always use sudo
sudo menu       # ✓ Correct
menu            # ✗ Wrong (will fail)
```

## 📦 Uninstallation

```bash
sudo bash uninstall-menus.sh
# Confirms before removing files
```

## 🔄 Alternative: All-in-One Script

If you prefer the original single-file version:
```bash
sudo bash vpn-aio-panel.sh
```

This has all features but doesn't support direct menu access.

## 📚 More Information

- **Detailed Guide**: [README-MENUS.md](README-MENUS.md)
- **Full Documentation**: [README.md](README.md)
- **Version History**: [CHANGELOG.md](CHANGELOG.md)
- **Structure Demo**: `bash demo-structure.sh`

## ⚡ One-Liner Commands

```bash
# Install and run
sudo bash install-menus.sh && sudo menu

# Test installation
bash test-menus.sh

# View structure
bash demo-structure.sh

# Quick SSH menu
sudo bash install-menus.sh && sudo ssh-menu

# Uninstall
sudo bash uninstall-menus.sh
```

## 🎓 Learning Path

1. **Start**: Run `bash demo-structure.sh` to understand structure
2. **Install**: Run `sudo bash install-menus.sh`
3. **Test**: Run `bash test-menus.sh` to verify
4. **Use**: Run `sudo menu` and explore
5. **Advanced**: Use direct menu commands like `sudo ssh-menu`

## 📋 Menu Cheatsheet

```
Main Menu Commands:
  01 = SSH Menu          11 = Tele Bot
  02 = VMESS Menu        12 = Update Menu
  03 = VLESS Menu        13 = Running Service
  04 = TROJAN Menu       14 = Info Port
  05 = NOOBZVPN          15 = Menu Bot
  06 = SS-LIBEV          16 = Change Domain
  07 = Install UDP       17 = Fix Cert
  08 = Backup/Restore    18 = Change Banner
  09 = GOTO X RAM        19 = Restart Banner
  10 = Restart All       20 = Speedtest
                         21 = Ekstrak Menu
  00 = Exit

SSH Menu Commands:
  1 = Add User
  2 = Delete User
  3 = Renew User
  4 = List Users
  5 = Show Logged-in
  0 = Back
```

---

**Need Help?** Check the detailed documentation in README-MENUS.md or README.md

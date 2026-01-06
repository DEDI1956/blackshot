# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2024-01-06

### Added - Modular Menu Structure

#### New Files
- `usr/bin/vpn-lib.sh` - Library dengan fungsi-fungsi bersama (shared functions)
- `usr/bin/menu` - Menu utama (main menu)
- `usr/bin/ssh-menu` - Menu manajemen akun SSH
- `usr/bin/vmess-menu` - Menu manajemen akun VMESS
- `usr/bin/vless-menu` - Menu manajemen akun VLESS
- `usr/bin/trojan-menu` - Menu manajemen akun TROJAN

#### Scripts & Documentation
- `install-menus.sh` - Script installer untuk setup otomatis
- `uninstall-menus.sh` - Script uninstaller untuk cleanup
- `test-menus.sh` - Test suite untuk validasi
- `README-MENUS.md` - Dokumentasi lengkap struktur modular

### Changed

#### Architecture
- **Modular Structure**: Script monolitik dipecah menjadi file-file terpisah
- **Bash Sourcing**: Menggunakan `source` untuk library functions
- **Independent Execution**: Setiap menu dapat dijalankan secara mandiri
- **Centralized Functions**: Semua fungsi utility dipindahkan ke vpn-lib.sh

#### Benefits
- ✅ **Maintainability**: Kode lebih mudah dikelola dan dimodifikasi
- ✅ **Reusability**: Fungsi dapat digunakan kembali di berbagai menu
- ✅ **Scalability**: Mudah menambah menu baru
- ✅ **Debugging**: Lebih mudah debug dengan kode yang terpisah
- ✅ **Compatibility**: Tetap kompatibel dengan script original

### Technical Details

#### Library Functions (vpn-lib.sh)
Berisi semua fungsi yang di-share:
- Hardening & safety settings (`set -euo pipefail`)
- Terminal styling & colors (tput-based)
- Utility functions (cls, pause, fmt_onoff)
- Service management (svc_is_active, svc_restart_if_exists)
- System information (get_os, get_cpu_cores, get_ram_usage, dll)
- Dashboard rendering (render_dashboard)
- Account counting (count_ssh_users, count_xray_accounts)
- Root privilege check (require_root)

#### Menu Structure
```
/usr/bin/
├── vpn-lib.sh      → Library (shared functions)
├── menu            → Main menu (calls other menus)
├── ssh-menu        → SSH account management
├── vmess-menu      → VMESS account management (XRAY)
├── vless-menu      → VLESS account management (XRAY)
└── trojan-menu     → TROJAN account management (XRAY)
```

#### Installation
```bash
# Automatic
sudo bash install-menus.sh

# Manual
sudo cp usr/bin/* /usr/bin/
sudo chmod +x /usr/bin/{vpn-lib.sh,menu,ssh-menu,vmess-menu,vless-menu,trojan-menu}
```

#### Usage
```bash
# Main menu
menu

# Individual menus
ssh-menu
vmess-menu
vless-menu
trojan-menu
```

### Maintained

#### Original Script
- `vpn-aio-panel.sh` - Script original tetap tersedia sebagai all-in-one version
- Semua fitur tetap berfungsi
- Backward compatibility terjaga

### Testing
- ✅ Syntax validation passed (bash -n)
- ✅ Library sourcing verified
- ✅ Function existence checked
- ✅ All 26 tests passed

## [1.0.0] - Initial Release

### Features
- All-in-one TUI panel untuk VPN management
- Dashboard dengan system information
- Service status monitoring
- SSH account management
- XRAY protocol support (VMESS, VLESS, TROJAN)
- Backup/Restore functionality
- Domain & Certificate management
- Speedtest integration

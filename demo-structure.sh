#!/usr/bin/env bash
# ============================================================================
# Demo script untuk menunjukkan struktur modular
# ============================================================================

cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    VPN All-in-One Panel - Modular Structure                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

📦 STRUKTUR FILE
════════════════════════════════════════════════════════════════════════════════

Project Root (/home/engine/project)
│
├── vpn-aio-panel.sh              ← Script original (all-in-one)
│
├── usr/bin/                       ← Menu scripts (modular)
│   ├── vpn-lib.sh                ← Library (shared functions)
│   ├── menu                      ← Main menu
│   ├── ssh-menu                  ← SSH management
│   ├── vmess-menu                ← VMESS management
│   ├── vless-menu                ← VLESS management
│   └── trojan-menu               ← TROJAN management
│
├── install-menus.sh              ← Installer
├── uninstall-menus.sh            ← Uninstaller
├── test-menus.sh                 ← Test suite
│
├── README.md                     ← Main documentation
├── README-MENUS.md               ← Modular structure guide
├── CHANGELOG.md                  ← Version history
└── .gitignore                    ← Git ignore rules

════════════════════════════════════════════════════════════════════════════════
🔗 BASH SOURCING - HOW IT WORKS
════════════════════════════════════════════════════════════════════════════════

1. vpn-lib.sh (Library)
   ├── Contains all shared functions
   ├── Styling & colors (tput)
   ├── System info (get_os, get_cpu_cores, etc)
   ├── Dashboard (render_dashboard)
   ├── Service control (svc_is_active, svc_restart_if_exists)
   └── Utility functions (cls, pause, fmt_onoff)

2. Individual Menus source the library:
   ┌─────────────────────────────────┐
   │ #!/usr/bin/env bash             │
   │ source /usr/bin/vpn-lib.sh      │  ← Import all functions
   │                                 │
   │ my_menu() {                     │
   │   print_header        # from lib│  ← Use library functions
   │   render_dashboard    # from lib│
   │   # menu code here              │
   │ }                               │
   │                                 │
   │ main() {                        │
   │   require_root        # from lib│
   │   my_menu                       │
   │ }                               │
   │ main "$@"                       │
   └─────────────────────────────────┘

════════════════════════════════════════════════════════════════════════════════
🚀 USAGE EXAMPLES
════════════════════════════════════════════════════════════════════════════════

Installation:
  $ sudo bash install-menus.sh

Main Menu (access all features):
  $ sudo menu

Direct Menu Access:
  $ sudo ssh-menu         # Direct to SSH management
  $ sudo vmess-menu       # Direct to VMESS management
  $ sudo vless-menu       # Direct to VLESS management
  $ sudo trojan-menu      # Direct to TROJAN management

Uninstall:
  $ sudo bash uninstall-menus.sh

Test:
  $ bash test-menus.sh

════════════════════════════════════════════════════════════════════════════════
✨ BENEFITS
════════════════════════════════════════════════════════════════════════════════

✓ Modular           - Each menu in separate file
✓ Maintainable      - Easy to update individual menus
✓ Reusable          - Shared functions via sourcing
✓ Scalable          - Easy to add new menus
✓ Independent       - Can call menus directly
✓ Compatible        - Works with original script
✓ Clean Code        - Better organization
✓ Debuggable        - Easier to troubleshoot

════════════════════════════════════════════════════════════════════════════════
📋 MENU FUNCTIONS MAP
════════════════════════════════════════════════════════════════════════════════

vpn-lib.sh (Library):
  ├── cls()                    - Clear screen
  ├── pause()                  - Wait for enter
  ├── fmt_onoff()              - Format ON/OFF status
  ├── svc_is_active()          - Check service status
  ├── svc_restart_if_exists()  - Restart service safely
  ├── require_root()           - Check root privileges
  ├── print_header()           - Display banner
  ├── get_os()                 - Get OS info
  ├── get_cpu_cores()          - Get CPU count
  ├── get_ram_usage()          - Get RAM usage
  ├── get_load()               - Get load average
  ├── get_uptime_pretty()      - Get uptime
  ├── get_public_ip()          - Get public IP
  ├── get_domain()             - Get configured domain
  ├── count_ssh_users()        - Count SSH users
  ├── count_xray_accounts()    - Count XRAY accounts
  ├── get_services_status()    - Get all service status
  └── render_dashboard()       - Render full dashboard

menu (Main):
  ├── print_main_menu()        - Display main menu
  ├── noobzvpn_menu()          - NOOBZVPN management
  ├── ss_libev_menu()          - Shadowsocks menu
  ├── backup_restore_menu()    - Backup & restore
  ├── restart_all_menu()       - Restart all services
  ├── speedtest_menu()         - Network speed test
  └── ... (plus 15 other menus)

ssh-menu:
  ├── ssh_menu()               - Main SSH menu
  ├── ssh_add_user()           - Add new SSH user
  ├── ssh_delete_user()        - Delete SSH user
  ├── ssh_renew_user()         - Extend user expiry
  ├── ssh_list_users()         - List all users
  └── ssh_show_logged_in()     - Show active sessions

vmess-menu, vless-menu, trojan-menu:
  └── *_menu()                 - Protocol-specific menus

════════════════════════════════════════════════════════════════════════════════
🎯 QUICK START
════════════════════════════════════════════════════════════════════════════════

Step 1: Install the menus
  $ sudo bash install-menus.sh

Step 2: Run main menu
  $ sudo menu

Step 3: Select option [01] for SSH menu

Step 4: Or directly access SSH menu
  $ sudo ssh-menu

════════════════════════════════════════════════════════════════════════════════
📞 FILES SUMMARY
════════════════════════════════════════════════════════════════════════════════

EOF

echo "Checking installed files..."
echo

files=(
  "usr/bin/vpn-lib.sh"
  "usr/bin/menu"
  "usr/bin/ssh-menu"
  "usr/bin/vmess-menu"
  "usr/bin/vless-menu"
  "usr/bin/trojan-menu"
  "install-menus.sh"
  "uninstall-menus.sh"
  "test-menus.sh"
  "README.md"
  "README-MENUS.md"
  "CHANGELOG.md"
)

for file in "${files[@]}"; do
  if [[ -f "/home/engine/project/$file" ]]; then
    size=$(du -h "/home/engine/project/$file" | cut -f1)
    printf "  ✓ %-25s [%5s]\n" "$file" "$size"
  else
    printf "  ✗ %-25s [MISSING]\n" "$file"
  fi
done

echo
echo "════════════════════════════════════════════════════════════════════════════════"
echo "🎉 VPN Panel Modular Structure Ready!"
echo "════════════════════════════════════════════════════════════════════════════════"
echo

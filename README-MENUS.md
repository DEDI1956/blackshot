# VPN All-in-One Panel - Modular Menu Structure

Script VPN TUI Panel telah dipecah menjadi struktur modular dengan bash sourcing.

## Struktur File

```
/usr/bin/
├── vpn-lib.sh      # Library functions (shared)
├── menu            # Menu utama
├── ssh-menu        # Menu manajemen SSH
├── vmess-menu      # Menu manajemen VMESS
├── vless-menu      # Menu manajemen VLESS
└── trojan-menu     # Menu manajemen TROJAN
```

## Instalasi

### Metode 1: Menggunakan Script Installer

```bash
sudo bash install-menus.sh
```

### Metode 2: Manual

```bash
# Copy semua file ke /usr/bin
sudo cp usr/bin/vpn-lib.sh /usr/bin/
sudo cp usr/bin/menu /usr/bin/
sudo cp usr/bin/ssh-menu /usr/bin/
sudo cp usr/bin/vmess-menu /usr/bin/
sudo cp usr/bin/vless-menu /usr/bin/
sudo cp usr/bin/trojan-menu /usr/bin/

# Set executable permission
sudo chmod +x /usr/bin/vpn-lib.sh
sudo chmod +x /usr/bin/menu
sudo chmod +x /usr/bin/ssh-menu
sudo chmod +x /usr/bin/vmess-menu
sudo chmod +x /usr/bin/vless-menu
sudo chmod +x /usr/bin/trojan-menu
```

## Penggunaan

### Menu Utama
```bash
menu
```

### Menu Individual
Setiap menu dapat dipanggil secara langsung:

```bash
ssh-menu      # Menu SSH
vmess-menu    # Menu VMESS
vless-menu    # Menu VLESS
trojan-menu   # Menu TROJAN
```

## Fitur

### vpn-lib.sh (Library)
Library ini berisi fungsi-fungsi bersama yang digunakan oleh semua menu:
- **Styling & Colors**: Fungsi untuk pewarnaan terminal (tput)
- **System Information**: get_os, get_cpu_cores, get_ram_usage, dll
- **Service Management**: svc_is_active, svc_restart_if_exists
- **Dashboard**: render_dashboard dengan informasi sistem dan service
- **Account Counting**: Fungsi untuk menghitung akun SSH dan XRAY

### menu (Main Menu)
Menu utama yang menyediakan akses ke:
- [01-04] Menu protokol VPN (SSH, VMESS, VLESS, TROJAN)
- [05-07] Menu tambahan (NOOBZVPN, SS-LIBEV, UDP)
- [08] Backup/Restore
- [09] GOTO X RAM
- [10] Restart All Services
- [11-15] Bot management
- [16-19] Domain & Banner management
- [20] Speedtest
- [21] Ekstrak Menu

### ssh-menu
Menu lengkap untuk manajemen akun SSH:
1. Add SSH User
2. Delete SSH User
3. Renew SSH User (Extend Expiry)
4. List SSH Users
5. Show Logged-in Users

### vmess-menu / vless-menu / trojan-menu
Menu placeholder untuk manajemen akun XRAY.
Struktur menu sudah tersedia, implementasi CRUD dapat disesuaikan dengan config XRAY yang digunakan.

## Keuntungan Modular Structure

1. **Maintainability**: Setiap menu dalam file terpisah, mudah dimodifikasi
2. **Reusability**: Fungsi umum di vpn-lib.sh dapat digunakan oleh semua menu
3. **Scalability**: Mudah menambah menu baru dengan sourcing vpn-lib.sh
4. **Debugging**: Lebih mudah debug karena kode terpisah per fungsi
5. **Independent Access**: Setiap menu dapat dipanggil langsung tanpa harus melalui menu utama

## Kompatibilitas

- ✅ Kompatibel dengan script utama `vpn-aio-panel.sh`
- ✅ Mendukung Ubuntu 20.04 / 22.04
- ✅ Menggunakan bash sourcing standar
- ✅ Semua fungsi dari script original tetap tersedia
- ✅ Dashboard dan monitoring tetap berfungsi

## Pengembangan

Untuk menambah menu baru:

1. Buat file baru di `/usr/bin/nama-menu`
2. Source library: `source /usr/bin/vpn-lib.sh`
3. Implementasikan fungsi menu Anda
4. Panggil `require_root` untuk cek privilege
5. Set executable: `chmod +x /usr/bin/nama-menu`
6. (Opsional) Tambahkan entry di menu utama

Contoh template:

```bash
#!/usr/bin/env bash
# Source library
source /usr/bin/vpn-lib.sh

my_custom_menu() {
  print_header
  render_dashboard
  # Your menu code here
}

main() {
  require_root
  my_custom_menu
}

main "$@"
```

## Troubleshooting

### Library tidak ditemukan
Pastikan `vpn-lib.sh` ada di `/usr/bin/` dan executable:
```bash
ls -la /usr/bin/vpn-lib.sh
sudo chmod +x /usr/bin/vpn-lib.sh
```

### Menu tidak bisa dijalankan
Pastikan semua file executable:
```bash
sudo chmod +x /usr/bin/menu
sudo chmod +x /usr/bin/ssh-menu
sudo chmod +x /usr/bin/vmess-menu
sudo chmod +x /usr/bin/vless-menu
sudo chmod +x /usr/bin/trojan-menu
```

### Harus dijalankan sebagai root
Semua menu memerlukan privilege root:
```bash
sudo menu
# atau
sudo ssh-menu
```

## Lisensi

Script ini adalah bagian dari VPN All-in-One Panel.

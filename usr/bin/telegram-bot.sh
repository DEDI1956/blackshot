#!/usr/bin/env bash
# ============================================================================
# Telegram Bot Integration for VPN Backup/Restore
# ============================================================================

# Source library functions
if [[ -f /usr/bin/vpn-lib.sh ]]; then
  # shellcheck disable=SC1091
  source /usr/bin/vpn-lib.sh
else
  echo "ERROR: Library /usr/bin/vpn-lib.sh tidak ditemukan!"
  exit 1
fi

# Telegram bot configuration
BOT_TOKEN=""
CHAT_ID=""
CONFIG_FILE="/etc/vpn-panel/telegram.env"

# Load configuration if exists
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1091
  source "$CONFIG_FILE"
fi

# Function to send Telegram message
send_telegram_message() {
  local message="$1"
  if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
    echo "Telegram bot not configured. Set BOT_TOKEN and CHAT_ID in $CONFIG_FILE"
    return 1
  fi
  
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found. Install with: apt install curl"
    return 1
  fi
  
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d text="${message}" \
    -d parse_mode="HTML" >/dev/null
  
  return $?
}

# Function to handle backup command from Telegram
telegram_backup() {
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  
  # Execute backup
  /usr/bin/env bash -c "
    source /usr/bin/vpn-lib.sh
    require_root
    
    local ts out
    ts='$(date +%Y%m%d-%H%M%S)'
    out='/root/backup/vpn-backup-\${ts}.tar.gz'
    
    mkdir -p /root/backup
    
    # Backup Xray config
    local xray_paths=()
    for p in /etc/xray /usr/local/etc/xray; do
      [[ -e \"\$p\" ]] && xray_paths+=(\"\$p\")
    done
    
    # Backup SSH accounts
    local ssh_backup='/tmp/ssh_backup_\${ts}'
    mkdir -p \"\${ssh_backup}\"
    
    [[ -f /etc/passwd ]] && cp /etc/passwd \"\${ssh_backup}/\"
    [[ -f /etc/shadow ]] && cp /etc/shadow \"\${ssh_backup}/\"
    [[ -f /etc/group ]] && cp /etc/group \"\${ssh_backup}/\"
    
    local home_backup='/tmp/home_backup_\${ts}'
    mkdir -p \"\${home_backup}\"
    while IFS=: read -r uname _ uid _ _ _ shell; do
      [[ \"\$uid\" -ge 1000 ]] || continue
      [[ \"\$uname\" != \"nobody\" ]] || continue
      [[ \"\$shell\" =~ (nologin|false)$ ]] && continue
      if [[ -d "/home/\$uname" ]]; then
        cp -r "/home/\$uname" \"\${home_backup}/\"
      fi
    done < /etc/passwd
    
    tar -czf \"\$out\" \"\${xray_paths[@]}\" \"\${ssh_backup}\" \"\${home_backup}\" 2>/dev/null || true
    rm -rf \"\${ssh_backup}\" \"\${home_backup}\"
    
    echo \"Backup completed: \$out\"
  " > /tmp/backup_${timestamp}.log 2>&1
  
  # Send notification
  local log_content
  log_content=$(cat "/tmp/backup_${timestamp}.log")
  send_telegram_message "✅ Backup completed:\n\n${log_content}"
  
  rm -f "/tmp/backup_${timestamp}.log"
}

# Function to handle restore command from Telegram
telegram_restore() {
  local file="$1"
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  
  if [[ -z "$file" || ! -f "$file" ]]; then
    send_telegram_message "❌ Restore failed: File not found"
    return 1
  fi
  
  # Execute restore
  /usr/bin/env bash -c "
    source /usr/bin/vpn-lib.sh
    require_root
    
    local temp_restore='/tmp/restore_${timestamp}'
    mkdir -p \"\$temp_restore\"
    tar -xzf \"${file}\" -C \"\$temp_restore\" 2>/dev/null || {
      echo 'Restore failed: Could not extract backup'
      exit 1
    }
    
    # Restore Xray config
    if [[ -d \"\$temp_restore/etc/xray\" ]]; then
      cp -r \"\$temp_restore/etc/xray\" /etc/
      echo 'Xray config restored'
    elif [[ -d \"\$temp_restore/usr/local/etc/xray\" ]]; then
      cp -r \"\$temp_restore/usr/local/etc/xray\" /usr/local/etc/
      echo 'Xray config restored'
    fi
    
    # Restore SSH accounts
    if [[ -d \"\$temp_restore/tmp/ssh_backup_*\" ]]; then
      local ssh_backup_dir=\$(find \"\$temp_restore/tmp\" -name \"ssh_backup_*\" -type d | head -1)
      if [[ -n \"\$ssh_backup_dir\" ]]; then
        while IFS=: read -r uname _ uid _ _ _ shell; do
          [[ \"\$uid\" -ge 1000 ]] || continue
          [[ \"\$uname\" != \"nobody\" ]] || continue
          [[ \"\$shell\" =~ (nologin|false)$ ]] && continue
          
          if [[ \"\$uname\" == \"root\" ]]; then
            continue
          fi
          
          if id -u \"\$uname\" >/dev/null 2>&1; then
            echo \"Account \$uname already exists, skipped\"
            continue
          fi
        done < \"\$ssh_backup_dir/passwd\"
        
        cp \"\$ssh_backup_dir/passwd\" /etc/passwd
        cp \"\$ssh_backup_dir/shadow\" /etc/shadow
        cp \"\$ssh_backup_dir/group\" /etc/group
        echo 'SSH accounts restored'
        
        local home_backup_dir=\$(find \"\$temp_restore/tmp\" -name \"home_backup_*\" -type d | head -1)
        if [[ -n \"\$home_backup_dir\" ]]; then
          cp -r \"\$home_backup_dir\"/* /home/
          chown -R --reference=/home /home
          echo 'Home directories restored'
        fi
      fi
    fi
    
    rm -rf \"\$temp_restore\"
    echo 'Restore completed successfully'
  " > /tmp/restore_${timestamp}.log 2>&1
  
  # Send notification
  local log_content
  log_content=$(cat "/tmp/restore_${timestamp}.log")
  send_telegram_message "✅ Restore completed:\n\n${log_content}"
  
  rm -f "/tmp/restore_${timestamp}.log"
}

# Main function to handle Telegram commands
main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [backup|restore FILE]"
    exit 1
  fi
  
  case "$1" in
    backup)
      telegram_backup
      ;;
    restore)
      if [[ $# -eq 2 ]]; then
        telegram_restore "$2"
      else
        echo "Usage for restore: $0 restore /path/to/backup.tar.gz"
        exit 1
      fi
      ;;
    *)
      echo "Unknown command: $1"
      echo "Usage: $0 [backup|restore FILE]"
      exit 1
      ;;
  esac
}

main "$@"

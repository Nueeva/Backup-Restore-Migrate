#!/bin/bash

Konfigurasi

BACKUP_DIR="/backup" LOG_FILE="/var/log/backup_restore.log" IP_VPS=$(hostname -I | awk '{print $1}') PTERO_DIR="/var/lib/pterodactyl" PTERO_DB="panel" PTERO_USER="pterodactyl" GITHUB_REPO="https://github.com/Nueeva/Backup_Restore_Migrate.git"

Konfigurasi Telegram

BOT_TOKEN="7251652217:AAEI0D4A-35KG_LuD4eseReZlUruXPXQOQ4" CHAT_ID="7053610236"

Fungsi konfirmasi

confirm() { read -p "$1 (y/n): " choice case "$choice" in y|Y ) return 0;; * ) echo -e "\n❌ Operasi dibatalkan!"; exit 1;; esac }

Fungsi Installasi Dependensi

install_dependencies() { confirm "⚠️ Apakah kamu ingin menginstall dependensi yang diperlukan?" apt update && apt install -y rsync mysql-client git curl echo -e "✔ Dependensi berhasil diinstal!" }

Fungsi Notifikasi Telegram

notify_telegram() { curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" 
-d chat_id=$CHAT_ID -d text="$1" -d parse_mode="Markdown" }

Fungsi Backup VPS

backup_vps() { confirm "⚠️ Apakah kamu yakin ingin membackup VPS?" BACKUP_PATH="$BACKUP_DIR/vps-$(date +%Y-%m-%d-%H%M).tar.gz" echo -e "\n⏳ Memulai backup VPS..." tar --exclude={"/tmp","/proc","/sys","/dev","/run","/mnt","/media","/lost+found"} -czf "$BACKUP_PATH" /etc /home /var /usr /opt /srv /root BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | awk '{print $1}') notify_telegram "📌 BACKUP VPS BERHASIL\n🖥 Server: `$IP_VPS`\n📅 Tanggal: `$(date)`\n📦 Ukuran: `$BACKUP_SIZE`\n📍 Lokasi: `$BACKUP_PATH`" echo -e "\n✔ Backup VPS selesai!" }

Fungsi Restore VPS

restore_vps() { confirm "⚠️ Apakah kamu yakin ingin merestore VPS? Ini akan menggantikan file yang ada!" echo -e "\n📌 Daftar backup yang tersedia:" ls -lh "$BACKUP_DIR"/*.tar.gz read -p "🔍 Masukkan nama file backup yang ingin direstore: " BACKUP_FILE tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C / notify_telegram "📌 RESTORE VPS BERHASIL\n🖥 Server: `$IP_VPS`\n📅 Tanggal: `$(date)`\n📂 Backup yang digunakan: `$BACKUP_FILE`" echo -e "\n✔ Restore VPS selesai!" }

Fungsi Backup Pterodactyl

backup_pterodactyl() { confirm "⚠️ Apakah kamu yakin ingin membackup Pterodactyl?" BACKUP_PATH="$BACKUP_DIR/pterodactyl-$(date +%Y-%m-%d-%H%M)" mkdir -p "$BACKUP_PATH" mysqldump -u "$PTERO_USER" "$PTERO_DB" > "$BACKUP_PATH/pterodactyl.sql" rsync -a --progress "$PTERO_DIR" "$BACKUP_PATH" tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "$(basename "$BACKUP_PATH")" && rm -rf "$BACKUP_PATH" notify_telegram "📌 BACKUP PTERODACTYL BERHASIL\n🖥 Server: `$IP_VPS`\n📅 Tanggal: `$(date)`\n📍 Lokasi: `$BACKUP_PATH.tar.gz`" echo -e "\n✔ Backup Pterodactyl selesai!" }

Fungsi Restore Pterodactyl

restore_pterodactyl() { confirm "⚠️ Apakah kamu yakin ingin merestore Pterodactyl?" echo -e "\n📌 Daftar backup yang tersedia:" ls -lh "$BACKUP_DIR"/*.tar.gz read -p "🔍 Masukkan nama file backup yang ingin direstore: " BACKUP_FILE tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C / mysql -u "$PTERO_USER" "$PTERO_DB" < "$BACKUP_DIR/$BACKUP_FILE/pterodactyl.sql" notify_telegram "📌 RESTORE PTERODACTYL BERHASIL\n🖥 Server: `$IP_VPS`\n📅 Tanggal: `$(date)`\n📂 Backup yang digunakan: `$BACKUP_FILE`" echo -e "\n✔ Restore Pterodactyl selesai!" }

Menu Utama

echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━\n📌 BACKUP & RESTORE MENU\n━━━━━━━━━━━━━━━━━━━━━━━" echo "1️⃣ Backup VPS" echo "2️⃣ Restore VPS" echo "3️⃣ Backup Pterodactyl" echo "4️⃣ Restore Pterodactyl" echo "5️⃣ Install Dependensi" echo "6️⃣ Keluar" read -p "🔍 Pilih opsi: " option

case $option in 1) backup_vps;; 2) restore_vps;; 3) backup_pterodactyl;; 4) restore_pterodactyl;; 5) install_dependencies;; 6) exit 0;; *) echo "❌ Opsi tidak valid!";; esac


#!/bin/bash

# Backup Management Script for Dell R420 Server
# This script helps manage and verify system backups

# Exit on error
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root"
        exit 1
    fi
}

# Function to check backup space
check_backup_space() {
    print_status "Checking backup space..."
    df -h /backup
    du -sh /backup/*
}

# Function to run rsnapshot backup
run_rsnapshot() {
    print_status "Running rsnapshot backup..."
    rsnapshot hourly
}

# Function to run Borg backup
run_borg_backup() {
    print_status "Running Borg backup..."
    BACKUP_DIR="/backup/system/borg"
    ARCHIVE_NAME="system-$(date +%Y%m%d-%H%M%S)"
    
    borg create \
        --verbose \
        --list \
        --stats \
        --show-rc \
        --compression lz4 \
        --exclude-caches \
        --exclude '/home/*/.cache/*' \
        --exclude '/var/cache/*' \
        --exclude '/var/tmp/*' \
        "$BACKUP_DIR::$ARCHIVE_NAME" \
        /etc \
        /home \
        /var \
        /usr/local
}

# Function to run Duplicity backup
run_duplicity_backup() {
    print_status "Running Duplicity backup..."
    source /etc/duplicity/conf.d/backup.conf
    
    duplicity \
        --full-if-older-than 7D \
        --encrypt-key $GPG_KEY \
        --exclude-filelist /etc/duplicity/exclude.txt \
        $EXCLUDE \
        $SOURCE \
        $TARGET
}

# Function to run Restic backup
run_restic_backup() {
    print_status "Running Restic backup..."
    export RESTIC_PASSWORD="your-password"
    export RESTIC_REPOSITORY="/backup/system/restic"
    
    restic backup \
        --exclude-file=/etc/restic/exclude.txt \
        /etc \
        /home \
        /var \
        /usr/local
}

# Function to verify backups
verify_backups() {
    print_status "Verifying backups..."
    
    # Verify rsnapshot
    print_status "Verifying rsnapshot..."
    rsnapshot -t hourly
    
    # Verify Borg
    print_status "Verifying Borg..."
    borg check /backup/system/borg
    
    # Verify Duplicity
    print_status "Verifying Duplicity..."
    duplicity verify /backup/system/duplicity /
    
    # Verify Restic
    print_status "Verifying Restic..."
    restic check
}

# Function to test backup restore
test_restore() {
    print_status "Testing backup restore..."
    
    # Create test directory
    TEST_DIR="/tmp/backup_test"
    mkdir -p $TEST_DIR
    
    # Test rsnapshot restore
    print_status "Testing rsnapshot restore..."
    cp -r /backup/system/rsnapshot/hourly.0/etc $TEST_DIR/rsnapshot_restore
    
    # Test Borg restore
    print_status "Testing Borg restore..."
    borg extract /backup/system/borg::system-$(date +%Y%m%d) --target $TEST_DIR/borg_restore
    
    # Test Duplicity restore
    print_status "Testing Duplicity restore..."
    duplicity restore /backup/system/duplicity --target $TEST_DIR/duplicity_restore
    
    # Test Restic restore
    print_status "Testing Restic restore..."
    restic restore latest --target $TEST_DIR/restic_restore
    
    print_status "Restore test completed. Check $TEST_DIR for results."
}

# Function to clean old backups
clean_backups() {
    print_status "Cleaning old backups..."
    
    # Clean rsnapshot
    print_status "Cleaning rsnapshot..."
    rsnapshot -t daily
    
    # Clean Borg
    print_status "Cleaning Borg..."
    borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=3 /backup/system/borg
    
    # Clean Duplicity
    print_status "Cleaning Duplicity..."
    duplicity remove-older-than 30D --force /backup/system/duplicity
    
    # Clean Restic
    print_status "Cleaning Restic..."
    restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3
}

# Function to show backup status
show_backup_status() {
    print_status "Backup Status:"
    
    echo -e "\nRsnapshot Status:"
    ls -l /backup/system/rsnapshot/
    
    echo -e "\nBorg Status:"
    borg list /backup/system/borg
    
    echo -e "\nDuplicity Status:"
    duplicity collection-status /backup/system/duplicity
    
    echo -e "\nRestic Status:"
    restic snapshots
}

# Function to configure backup schedule
configure_schedule() {
    print_status "Configuring backup schedule..."
    
    # Configure cron jobs
    (crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/backup-rsnapshot.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-borg.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/local/bin/backup-duplicity.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 4 * * * /usr/local/bin/backup-restic.sh") | crontab -
    
    print_status "Current cron jobs:"
    crontab -l
}

# Main menu function
show_menu() {
    echo -e "\nBackup Management Menu:"
    echo "1. Show backup status"
    echo "2. Check backup space"
    echo "3. Run all backups"
    echo "4. Verify backups"
    echo "5. Test backup restore"
    echo "6. Clean old backups"
    echo "7. Configure backup schedule"
    echo "8. Exit"
    
    read -p "Enter your choice (1-8): " choice
    
    case $choice in
        1)
            show_backup_status
            ;;
        2)
            check_backup_space
            ;;
        3)
            run_rsnapshot
            run_borg_backup
            run_duplicity_backup
            run_restic_backup
            ;;
        4)
            verify_backups
            ;;
        5)
            test_restore
            ;;
        6)
            clean_backups
            ;;
        7)
            configure_schedule
            ;;
        8)
            print_status "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    echo
    show_menu
}

# Main function
main() {
    print_status "Starting Backup Management Tool..."
    
    check_root
    
    # Show initial backup status
    show_backup_status
    
    # Show menu
    show_menu
}

# Run main function
main 
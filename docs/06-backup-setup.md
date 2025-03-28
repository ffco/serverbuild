# Backup System Setup Guide

This guide covers the configuration and management of the backup system for your Dell R420 server.

## Backup Storage Configuration
1. Verify backup storage:
   ```bash
   sudo mdadm --detail /dev/md1
   df -h /backup
   ```

2. Create backup directory structure:
   ```bash
   sudo mkdir -p /backup/{system,config,data}
   sudo chmod 700 /backup
   ```

## Backup Software Installation
1. Install backup tools:
   ```bash
   sudo apt install -y \
     rsnapshot \
     borgbackup \
     duplicity \
     restic
   ```

2. Configure rsnapshot:
   ```bash
   sudo cp /etc/rsnapshot.conf /etc/rsnapshot.conf.local
   sudo nano /etc/rsnapshot.conf.local
   ```
   Set:
   ```text
   snapshot_root   /backup/system/rsnapshot/
   retain          hourly  6
   retain          daily   7
   retain          weekly  4
   retain          monthly 3
   
   backup          /etc/           localhost/
   backup          /home/          localhost/
   backup          /var/           localhost/
   backup          /usr/local/     localhost/
   ```

## Borg Backup Setup
1. Initialize Borg repository:
   ```bash
   borg init --encryption=repokey /backup/system/borg
   ```

2. Create backup script:
   ```bash
   sudo nano /usr/local/bin/backup-borg.sh
   ```
   Add:
   ```bash
   #!/bin/bash
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
   ```

## Duplicity Setup
1. Configure Duplicity:
   ```bash
   sudo nano /etc/duplicity/conf.d/backup.conf
   ```
   Add:
   ```text
   GPG_KEY="your-gpg-key-id"
   PASSPHRASE="your-passphrase"
   TARGET="file:///backup/system/duplicity"
   SOURCE="/"
   EXCLUDE="--exclude /proc --exclude /sys --exclude /tmp --exclude /run --exclude /mnt --exclude /media --exclude /lost+found --exclude /backup"
   ```

2. Create backup script:
   ```bash
   sudo nano /usr/local/bin/backup-duplicity.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   source /etc/duplicity/conf.d/backup.conf
   
   duplicity \
     --full-if-older-than 7D \
     --encrypt-key $GPG_KEY \
     --exclude-filelist /etc/duplicity/exclude.txt \
     $EXCLUDE \
     $SOURCE \
     $TARGET
   ```

## Restic Setup
1. Initialize Restic repository:
   ```bash
   restic init --repo /backup/system/restic
   ```

2. Create backup script:
   ```bash
   sudo nano /usr/local/bin/backup-restic.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   export RESTIC_PASSWORD="your-password"
   export RESTIC_REPOSITORY="/backup/system/restic"
   
   restic backup \
     --exclude-file=/etc/restic/exclude.txt \
     /etc \
     /home \
     /var \
     /usr/local
   ```

## Backup Scheduling
1. Configure cron jobs:
   ```bash
   sudo crontab -e
   ```
   Add:
   ```text
   # Hourly rsnapshot
   0 * * * * /usr/local/bin/backup-rsnapshot.sh
   
   # Daily Borg backup
   0 2 * * * /usr/local/bin/backup-borg.sh
   
   # Weekly Duplicity backup
   0 3 * * 0 /usr/local/bin/backup-duplicity.sh
   
   # Daily Restic backup
   0 4 * * * /usr/local/bin/backup-restic.sh
   ```

## Backup Verification
1. Create verification script:
   ```bash
   sudo nano /usr/local/bin/verify-backups.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   
   # Check rsnapshot
   rsnapshot -t hourly
   
   # Check Borg
   borg check /backup/system/borg
   
   # Check Duplicity
   duplicity verify /backup/system/duplicity /
   
   # Check Restic
   restic check
   ```

## Backup Monitoring
1. Install monitoring tools:
   ```bash
   sudo apt install -y \
     prometheus-node-exporter \
     grafana
   ```

2. Configure monitoring:
   ```bash
   sudo nano /etc/prometheus/node_exporter/textfile/backup.prom
   ```
   Add:
   ```text
   backup_last_success{type="rsnapshot"} $(date +%s)
   backup_last_success{type="borg"} $(date +%s)
   backup_last_success{type="duplicity"} $(date +%s)
   backup_last_success{type="restic"} $(date +%s)
   ```

## Backup Cleanup
1. Create cleanup script:
   ```bash
   sudo nano /usr/local/bin/cleanup-backups.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   
   # Cleanup rsnapshot
   rsnapshot -t daily
   
   # Cleanup Borg
   borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=3 /backup/system/borg
   
   # Cleanup Duplicity
   duplicity remove-older-than 30D --force /backup/system/duplicity
   
   # Cleanup Restic
   restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3
   ```

## Backup Testing
1. Create test script:
   ```bash
   sudo nano /usr/local/bin/test-backups.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   
   # Test rsnapshot restore
   cp -r /backup/system/rsnapshot/hourly.0/etc /tmp/restore_test
   
   # Test Borg restore
   borg extract /backup/system/borg::system-$(date +%Y%m%d) /tmp/restore_test_borg
   
   # Test Duplicity restore
   duplicity restore /backup/system/duplicity /tmp/restore_test_duplicity
   
   # Test Restic restore
   restic restore latest --target /tmp/restore_test_restic
   ```

## Next Steps
After completing backup setup, proceed to the [Maintenance Procedures](08-maintenance.md) guide.

## Troubleshooting
Common issues and solutions:
1. Backup failures:
   - Check disk space
   - Verify permissions
   - Review logs

2. Restore problems:
   - Verify backup integrity
   - Check restore paths
   - Test restore process

3. Performance issues:
   - Monitor backup duration
   - Check system resources
   - Review backup logs

## Notes
- Regular backup testing
- Monitor backup space
- Document restore procedures
- Keep backup logs 
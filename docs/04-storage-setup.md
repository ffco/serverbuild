# Storage Configuration Guide

This guide covers the configuration of storage systems for your Dell R420 server, including RAID setup and backup configuration.

## RAID Configuration
1. Check disk status:
   ```bash
   sudo fdisk -l
   sudo lsblk
   ```

2. Create RAID 1 for SSDs:
   ```bash
   # Create RAID array
   sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdb
   
   # Wait for sync to complete
   sudo watch -n 1 cat /proc/mdstat
   ```

3. Configure RAID monitoring:
   ```bash
   sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
   sudo update-initramfs -u
   ```

## LVM Setup
1. Create physical volumes:
   ```bash
   sudo pvcreate /dev/md0
   ```

2. Create volume group:
   ```bash
   sudo vgcreate vg0 /dev/md0
   ```

3. Create logical volumes:
   ```bash
   # Boot partition
   sudo lvcreate -L 1G -n boot vg0
   
   # Root partition
   sudo lvcreate -L 50G -n root vg0
   
   # Home partition
   sudo lvcreate -L 100G -n home vg0
   
   # Var partition
   sudo lvcreate -L 20G -n var vg0
   
   # Swap partition
   sudo lvcreate -L 16G -n swap vg0
   ```

## Filesystem Setup
1. Format partitions:
   ```bash
   sudo mkfs.ext4 /dev/vg0/boot
   sudo mkfs.ext4 /dev/vg0/root
   sudo mkfs.ext4 /dev/vg0/home
   sudo mkfs.ext4 /dev/vg0/var
   sudo mkswap /dev/vg0/swap
   ```

2. Mount points:
   ```bash
   sudo mount /dev/vg0/root /mnt
   sudo mkdir -p /mnt/{boot,home,var}
   sudo mount /dev/vg0/boot /mnt/boot
   sudo mount /dev/vg0/home /mnt/home
   sudo mount /dev/vg0/var /mnt/var
   ```

## Backup Storage Setup
1. Configure backup drives:
   ```bash
   # Create RAID 1 for backup drives
   sudo mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sdc /dev/sdd
   
   # Create filesystem
   sudo mkfs.ext4 /dev/md1
   ```

2. Create backup mount point:
   ```bash
   sudo mkdir -p /backup
   sudo mount /dev/md1 /backup
   ```

3. Configure fstab:
   ```bash
   sudo nano /etc/fstab
   ```
   Add:
   ```text
   /dev/vg0/boot    /boot    ext4    defaults    0 2
   /dev/vg0/root    /        ext4    defaults    0 1
   /dev/vg0/home    /home    ext4    defaults    0 2
   /dev/vg0/var     /var     ext4    defaults    0 2
   /dev/vg0/swap    none     swap    sw          0 0
   /dev/md1         /backup  ext4    defaults    0 2
   ```

## Backup System Setup
1. Install backup tools:
   ```bash
   sudo apt install -y \
     rsync \
     rsnapshot \
     borgbackup
   ```

2. Configure rsnapshot:
   ```bash
   sudo cp /etc/rsnapshot.conf /etc/rsnapshot.conf.local
   sudo nano /etc/rsnapshot.conf.local
   ```
   Set:
   ```text
   snapshot_root   /backup/rsnapshot/
   retain          hourly  6
   retain          daily   7
   retain          weekly  4
   retain          monthly 3
   ```

3. Create backup script:
   ```bash
   sudo nano /usr/local/bin/backup.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   rsnapshot hourly
   ```

4. Set up cron job:
   ```bash
   sudo crontab -e
   ```
   Add:
   ```text
   0 * * * * /usr/local/bin/backup.sh
   ```

## Monitoring Setup
1. Install monitoring tools:
   ```bash
   sudo apt install -y \
     smartmontools \
     iotop \
     htop
   ```

2. Configure SMART monitoring:
   ```bash
   sudo smartctl -a /dev/sda
   sudo smartctl -a /dev/sdb
   sudo smartctl -a /dev/sdc
   sudo smartctl -a /dev/sdd
   ```

3. Set up disk monitoring:
   ```bash
   sudo nano /etc/smartd.conf
   ```
   Add:
   ```text
   DEVICESCAN -d auto -n never -a -s (S/../.././02|L/../../6/03)
   ```

## Verification
1. Check RAID status:
   ```bash
   sudo mdadm --detail /dev/md0
   sudo mdadm --detail /dev/md1
   ```

2. Verify LVM setup:
   ```bash
   sudo pvs
   sudo vgs
   sudo lvs
   ```

3. Test backup system:
   ```bash
   sudo rsnapshot hourly
   ls -l /backup/rsnapshot/
   ```

## Next Steps
After completing storage setup, proceed to the [Network Configuration](06-network-setup.md) guide.

## Troubleshooting
Common issues and solutions:
1. RAID problems:
   - Check disk health
   - Verify RAID status
   - Check sync progress

2. LVM issues:
   - Verify physical volumes
   - Check volume groups
   - Review logical volumes

3. Backup failures:
   - Check disk space
   - Verify permissions
   - Review logs

## Notes
- Regular backup testing
- Monitor disk health
- Keep RAID status logs
- Document storage layout 
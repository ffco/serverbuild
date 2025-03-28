# Ubuntu Server Installation Guide

This guide covers the installation of Ubuntu Server LTS on your Dell R420 server.

## Prerequisites
- USB drive (8GB or larger)
- Ubuntu Server LTS ISO image
- Network connection
- iDRAC access configured
- Keyboard and monitor (or KVM over IP)

## Preparing Installation Media
1. Download Ubuntu Server LTS:
   - Visit [Ubuntu Server Downloads](https://ubuntu.com/download/server)
   - Download the latest LTS version
   - Verify ISO checksum

2. Create bootable USB:
   ```bash
   # On Linux/Mac
   dd if=ubuntu-server.iso of=/dev/sdX bs=4M status=progress
   
   # On Windows
   # Use Rufus or similar tool
   ```

## Installation Steps
1. Boot from USB:
   - Insert USB drive
   - Power on server
   - Select USB as boot device
   - Wait for GRUB menu

2. Start installation:
   - Select "Install Ubuntu Server"
   - Choose language
   - Select keyboard layout
   - Configure network connection

3. System configuration:
   - Set hostname
   - Create initial user account
   - Set strong password
   - Configure proxy if needed

4. Storage configuration:
   - Select "Manual" partitioning
   - Configure RAID for SSDs:
     - Create RAID 1 for system
     - Create separate partitions for:
       - /boot
       - / (root)
       - /home
       - /var
       - /tmp
   - Configure swap space
   - Review and confirm changes

5. System setup:
   - Install GRUB boot loader
   - Configure timezone
   - Select software to install:
     - OpenSSH server
     - Standard system utilities
     - Basic monitoring tools

## Post-Installation Steps
1. First boot:
   - Login with created user
   - Update system:
     ```bash
     sudo apt update
     sudo apt upgrade -y
     ```

2. Install additional packages:
   ```bash
   sudo apt install -y \
     ufw \
     fail2ban \
     htop \
     iotop \
     smartmontools \
     mdadm \
     lvm2
   ```

3. Configure basic security:
   ```bash
   # Enable UFW
   sudo ufw enable
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   ```

## Verification
1. Check system status:
   ```bash
   # Check RAID status
   sudo mdadm --detail /dev/md0
   
   # Check disk health
   sudo smartctl -a /dev/sda
   
   # Verify network
   ip addr show
   ```

2. Test remote access:
   ```bash
   # From another machine
   ssh username@server_ip
   ```

## Next Steps
After completing the installation, proceed to the [Security Configuration](04-security-setup.md) guide.

## Troubleshooting
Common issues and solutions:
1. Boot problems:
   - Check BIOS settings
   - Verify USB boot order
   - Check RAID configuration

2. Network issues:
   - Verify network cable
   - Check IP configuration
   - Test DNS resolution

3. Storage problems:
   - Verify RAID status
   - Check disk health
   - Review partition layout

## Notes
- Document all passwords securely
- Keep installation media safe
- Note any custom configurations
- Save system logs for reference 
# Security Configuration Guide

This guide covers the security hardening of your Ubuntu Server installation.

## System Updates
1. Configure automatic updates:
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure unattended-upgrades
   ```

2. Configure update notifications:
   ```bash
   sudo apt install apticron
   sudo nano /etc/apticron/apticron.conf
   # Set EMAIL="your-email@example.com"
   ```

## SSH Security
1. Configure SSH daemon:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   Set the following:
   ```text
   PermitRootLogin no
   PasswordAuthentication no
   X11Forwarding no
   MaxAuthTries 3
   LoginGraceTime 60
   ClientAliveInterval 300
   ClientAliveCountMax 3
   ```

2. Generate SSH keys for users:
   ```bash
   # On client machine
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ssh-copy-id username@server_ip
   ```

## Firewall Configuration
1. Configure UFW:
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw enable
   ```

2. Add specific rules:
   ```bash
   # Allow specific services
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   # Add other necessary ports
   ```

## Fail2ban Setup
1. Configure fail2ban:
   ```bash
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   sudo nano /etc/fail2ban/jail.local
   ```
   Set:
   ```text
   [DEFAULT]
   bantime = 1h
   findtime = 10m
   maxretry = 3
   ```

2. Enable jails:
   ```bash
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

## System Hardening
1. Install security packages:
   ```bash
   sudo apt install -y \
     apparmor \
     apparmor-utils \
     auditd \
     rkhunter \
     lynis
   ```

2. Configure AppArmor:
   ```bash
   sudo systemctl enable apparmor
   sudo systemctl start apparmor
   sudo aa-enforce /etc/apparmor.d/*
   ```

3. Configure auditd:
   ```bash
   sudo systemctl enable auditd
   sudo systemctl start auditd
   ```

## User Security
1. Password policies:
   ```bash
   sudo nano /etc/security/pwquality.conf
   ```
   Set:
   ```text
   minlen = 12
   dcredit = -1
   ucredit = -1
   ocredit = -1
   lcredit = -1
   ```

2. Configure sudo access:
   ```bash
   sudo visudo
   ```
   Add:
   ```text
   Defaults        env_reset
   Defaults        mail_badpass
   Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
   ```

## Network Security
1. Configure TCP wrappers:
   ```bash
   sudo nano /etc/hosts.allow
   ```
   Add:
   ```text
   sshd: ALLOWED_IP_RANGES
   ```

2. Configure system limits:
   ```bash
   sudo nano /etc/security/limits.conf
   ```
   Add:
   ```text
   * soft nofile 65535
   * hard nofile 65535
   ```

## Monitoring and Logging
1. Configure log rotation:
   ```bash
   sudo nano /etc/logrotate.conf
   ```
   Set:
   ```text
   rotate 12
   weekly
   compress
   delaycompress
   missingok
   notifempty
   create 0640 root root
   ```

2. Install monitoring tools:
   ```bash
   sudo apt install -y \
     logwatch \
     logcheck \
     aide
   ```

## Regular Security Tasks
1. System audit:
   ```bash
   # Run rkhunter
   sudo rkhunter --update
   sudo rkhunter --propupd
   sudo rkhunter --check

   # Run lynis
   sudo lynis audit system
   ```

2. Log review:
   ```bash
   # Check auth logs
   sudo tail -f /var/log/auth.log

   # Check system logs
   sudo journalctl -f
   ```

## Next Steps
After completing security setup, proceed to the [Storage Configuration](05-storage-setup.md) guide.

## Troubleshooting
Common issues and solutions:
1. SSH access problems:
   - Check SSH config
   - Verify key permissions
   - Check firewall rules

2. Firewall issues:
   - Verify UFW status
   - Check rule order
   - Test connectivity

3. Monitoring problems:
   - Check log permissions
   - Verify service status
   - Test alert system

## Notes
- Keep security configurations documented
- Regular security audits
- Monitor system logs
- Update security tools regularly 
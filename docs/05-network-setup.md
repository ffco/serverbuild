# Network Configuration Guide

This guide covers the network configuration for your Dell R420 server, including static IP setup, DNS configuration, and network security.

## Network Interface Configuration
1. Identify network interfaces:
   ```bash
   ip link show
   ```

2. Configure static IP:
   ```bash
   sudo nano /etc/netplan/01-netcfg.yaml
   ```
   Add:
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       eno1:
         dhcp4: no
         addresses:
           - 192.168.1.100/24
         gateway4: 192.168.1.1
         nameservers:
           addresses: [8.8.8.8, 8.8.4.4]
   ```

3. Apply network configuration:
   ```bash
   sudo netplan apply
   ```

## DNS Configuration
1. Configure local DNS:
   ```bash
   sudo nano /etc/systemd/resolved.conf
   ```
   Set:
   ```text
   [Resolve]
   DNS=8.8.8.8 8.8.4.4
   FallbackDNS=1.1.1.1
   DNSSEC=yes
   ```

2. Enable DNS service:
   ```bash
   sudo systemctl enable systemd-resolved
   sudo systemctl start systemd-resolved
   ```

## Network Security
1. Configure UFW rules:
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. Set up fail2ban:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```
   Add:
   ```text
   [sshd]
   enabled = true
   port = ssh
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   ```

## Network Monitoring
1. Install monitoring tools:
   ```bash
   sudo apt install -y \
     iftop \
     net-tools \
     tcpdump \
     nethogs
   ```

2. Configure network monitoring:
   ```bash
   sudo nano /etc/sysctl.conf
   ```
   Add:
   ```text
   net.ipv4.tcp_syncookies = 1
   net.ipv4.tcp_max_syn_backlog = 2048
   net.ipv4.tcp_synack_retries = 2
   net.ipv4.tcp_syn_retries = 5
   ```

## Network Performance Tuning
1. Configure network buffers:
   ```bash
   sudo nano /etc/sysctl.conf
   ```
   Add:
   ```text
   net.core.rmem_max = 16777216
   net.core.wmem_max = 16777216
   net.ipv4.tcp_rmem = 4096 87380 16777216
   net.ipv4.tcp_wmem = 4096 65536 16777216
   ```

2. Apply sysctl settings:
   ```bash
   sudo sysctl -p
   ```

## Network Backup Configuration
1. Configure network backup:
   ```bash
   sudo nano /etc/rsnapshot.conf
   ```
   Add:
   ```text
   backup_script    /usr/local/bin/backup-network.sh    network_backup/
   ```

2. Create backup script:
   ```bash
   sudo nano /usr/local/bin/backup-network.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   # Backup network configurations
   tar -czf /backup/network-config-$(date +%Y%m%d).tar.gz /etc/netplan /etc/systemd/resolved.conf
   ```

## Network Troubleshooting Tools
1. Install diagnostic tools:
   ```bash
   sudo apt install -y \
     mtr \
     traceroute \
     dnsutils \
     netcat
   ```

2. Create diagnostic script:
   ```bash
   sudo nano /usr/local/bin/network-diagnostic.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   echo "Network Interface Status:"
   ip link show
   echo -e "\nRouting Table:"
   ip route
   echo -e "\nDNS Configuration:"
   cat /etc/resolv.conf
   echo -e "\nNetwork Connections:"
   netstat -tuln
   ```

## Network Mobility Setup
1. Create network change script:
   ```bash
   sudo nano /usr/local/bin/change-network.sh
   ```
   Add:
   ```bash
   #!/bin/bash
   # Network change script
   read -p "Enter new IP address: " new_ip
   read -p "Enter new subnet mask: " new_mask
   read -p "Enter new gateway: " new_gateway
   
   sudo sed -i "s/addresses: \[.*\]/addresses: [$new_ip\/$new_mask]/" /etc/netplan/01-netcfg.yaml
   sudo sed -i "s/gateway4: .*/gateway4: $new_gateway/" /etc/netplan/01-netcfg.yaml
   
   sudo netplan apply
   ```

2. Make script executable:
   ```bash
   sudo chmod +x /usr/local/bin/change-network.sh
   ```

## Verification
1. Check network configuration:
   ```bash
   ip addr show
   ip route
   ping -c 4 8.8.8.8
   ```

2. Test DNS resolution:
   ```bash
   nslookup google.com
   dig google.com
   ```

3. Verify firewall rules:
   ```bash
   sudo ufw status verbose
   ```

## Next Steps
After completing network setup, proceed to the [Backup System Setup](07-backup-setup.md) guide.

## Troubleshooting
Common issues and solutions:
1. Network connectivity:
   - Check physical connections
   - Verify IP configuration
   - Test DNS resolution

2. Firewall issues:
   - Review UFW rules
   - Check service ports
   - Test connectivity

3. Performance problems:
   - Monitor bandwidth
   - Check system resources
   - Review network logs

## Notes
- Document network settings
- Keep backup of configurations
- Monitor network performance
- Regular security updates 
# Maintenance Procedures Guide

This guide covers regular maintenance procedures for your Dell R420 server.

## System Updates
1. Check for updates:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. Clean up old packages:
   ```bash
   sudo apt autoremove -y
   sudo apt clean
   ```

## Disk Maintenance
1. Check disk health:
   ```bash
   sudo smartctl -a /dev/sda
   sudo smartctl -a /dev/sdb
   sudo smartctl -a /dev/sdc
   sudo smartctl -a /dev/sdd
   ```

2. Check filesystem health:
   ```bash
   sudo fsck -f /dev/vg0/root
   sudo fsck -f /dev/vg0/home
   sudo fsck -f /dev/vg0/var
   ```

3. Monitor disk space:
   ```bash
   df -h
   du -sh /* | sort -hr | head -n 10
   ```

## RAID Maintenance
1. Check RAID status:
   ```bash
   sudo mdadm --detail /dev/md0
   sudo mdadm --detail /dev/md1
   ```

2. Monitor RAID sync:
   ```bash
   cat /proc/mdstat
   ```

3. Check for failed drives:
   ```bash
   sudo mdadm --monitor --scan --daemonise
   ```

## Backup Verification
1. Check backup status:
   ```bash
   sudo /usr/local/bin/verify-backups.sh
   ```

2. Test backup restore:
   ```bash
   sudo /usr/local/bin/test-backups.sh
   ```

3. Clean old backups:
   ```bash
   sudo /usr/local/bin/cleanup-backups.sh
   ```

## Log Management
1. Check system logs:
   ```bash
   sudo journalctl -n 100
   sudo tail -f /var/log/syslog
   ```

2. Check auth logs:
   ```bash
   sudo tail -f /var/log/auth.log
   ```

3. Check application logs:
   ```bash
   sudo tail -f /var/log/application.log
   ```

## Performance Monitoring
1. Check system resources:
   ```bash
   htop
   iotop
   ```

2. Check network usage:
   ```bash
   iftop
   nethogs
   ```

3. Monitor system metrics:
   ```bash
   # CPU usage
   mpstat 1 5
   
   # Memory usage
   free -m
   
   # Disk I/O
   iostat -x 1 5
   ```

## Security Maintenance
1. Check security updates:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. Run security audit:
   ```bash
   sudo lynis audit system
   sudo rkhunter --check
   ```

3. Check firewall rules:
   ```bash
   sudo ufw status verbose
   ```

## Network Maintenance
1. Check network status:
   ```bash
   ip addr show
   ip route
   ```

2. Test network connectivity:
   ```bash
   ping -c 4 8.8.8.8
   traceroute google.com
   ```

3. Check DNS resolution:
   ```bash
   nslookup google.com
   dig google.com
   ```

## System Cleanup
1. Clean temporary files:
   ```bash
   sudo rm -rf /tmp/*
   sudo rm -rf /var/tmp/*
   ```

2. Clean old logs:
   ```bash
   sudo journalctl --vacuum-time=7d
   sudo find /var/log -type f -name "*.gz" -delete
   ```

3. Clean package cache:
   ```bash
   sudo apt clean
   sudo apt autoremove -y
   ```

## Maintenance Schedule
1. Daily tasks:
   ```bash
   # Check system logs
   # Monitor disk space
   # Verify backups
   # Check security alerts
   ```

2. Weekly tasks:
   ```bash
   # Full system update
   # Backup verification
   # Security audit
   # Performance check
   ```

3. Monthly tasks:
   ```bash
   # Deep system cleanup
   # Full backup test
   # Comprehensive security scan
   # System optimization
   ```

## Emergency Procedures
1. System recovery:
   ```bash
   # Boot from recovery media
   # Mount RAID array
   # Restore from backup
   # Verify system
   ```

2. Data recovery:
   ```bash
   # Identify failed drive
   # Replace drive
   # Rebuild RAID
   # Verify data
   ```

3. Network recovery:
   ```bash
   # Check physical connections
   # Verify network config
   # Test connectivity
   # Restore network
   ```

## Documentation
1. Update system documentation:
   ```bash
   # Document changes
   # Update procedures
   # Review configurations
   # Update contact info
   ```

2. Backup documentation:
   ```bash
   # Export configurations
   # Save procedures
   # Document passwords
   # Update inventory
   ```

## Next Steps
After completing maintenance procedures, review the [Initial Server Setup](01-initial-setup.md) guide for any necessary updates.

## Troubleshooting
Common issues and solutions:
1. System problems:
   - Check logs
   - Monitor resources
   - Verify configurations

2. Performance issues:
   - Check system load
   - Monitor resources
   - Review processes

3. Security concerns:
   - Check logs
   - Review rules
   - Update systems

## Notes
- Keep maintenance logs
- Document all changes
- Regular testing
- Update procedures 
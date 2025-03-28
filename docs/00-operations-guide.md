# Dell R420 Server Operations Guide

## Overview
This guide provides essential information for users and administrators of our Dell R420 server. The server is configured for high reliability, security, and performance, with automated maintenance and monitoring systems in place.

## Server Specifications
- **Hardware**: Dell R420 Server
- **Operating System**: Ubuntu Server LTS (No GUI)
- **Storage**:
  - System Drives: 2x 250GB SSDs in RAID 1
  - Backup Drives: 2x 10TB spinning disks in RAID 1
- **Remote Management**: iDRAC for out-of-band management
- **Network**: Public-facing with secure remote access

## Key Features
1. **Redundant Storage**
   - System drives (SSDs) are mirrored for reliability
   - Backup drives are mirrored and separate from system drives
   - Automated backup system with multiple backup tools

2. **Security**
   - SSH key-based authentication only (no password login)
   - UFW firewall with minimal open ports
   - Fail2ban for brute force protection
   - Regular security updates

3. **Monitoring**
   - Real-time system monitoring
   - Automated health checks
   - Performance monitoring
   - Log management

## Access and Management

### Remote Access
1. **SSH Access**
   ```bash
   ssh -i /path/to/your/key.pem username@server-ip
   ```
   - Only SSH key authentication is allowed
   - Password login is disabled for security

2. **iDRAC Access**
   - Access via web browser: `https://server-ip:443`
   - Used for hardware monitoring and remote console
   - Separate credentials from system access

### Management Tools
1. **System Monitoring**
   ```bash
   sudo ./scripts/system-monitor.sh
   ```
   - Provides menu-driven interface for:
     - System resource monitoring
     - Disk health checks
     - RAID status
     - Network monitoring
     - Log viewing
     - Maintenance tasks

2. **Network Configuration**
   ```bash
   sudo ./scripts/network-config.sh
   ```
   - Manages network settings
   - Handles IP address changes
   - Configures firewall rules

3. **Backup Management**
   ```bash
   sudo ./scripts/backup-manager.sh
   ```
   - Manages backup operations
   - Verifies backup integrity
   - Configures backup schedules

## Operational Considerations

### System Maintenance
1. **Regular Updates**
   - System updates are automated
   - Security patches are applied automatically
   - Maintenance windows are scheduled

2. **Backup Schedule**
   - Daily incremental backups
   - Weekly full backups
   - Monthly backup verification
   - 30-day retention period

3. **Monitoring**
   - System resources are monitored 24/7
   - Alerts are sent for:
     - High CPU/Memory usage
     - Disk space issues
     - RAID degradation
     - Failed login attempts

### Best Practices
1. **Security**
   - Never share SSH keys
   - Use strong passphrases for SSH keys
   - Report any suspicious activity
   - Keep local copies of SSH keys secure

2. **Performance**
   - Monitor system resources regularly
   - Clean up old logs and temporary files
   - Report any performance issues

3. **Backup Management**
   - Verify backup integrity regularly
   - Test restore procedures
   - Monitor backup space usage

### Emergency Procedures
1. **System Issues**
   - Check system logs: `sudo journalctl -n 100`
   - Monitor RAID status: `sudo mdadm --detail /dev/md0`
   - Check disk health: `sudo smartctl -a /dev/sda`

2. **Network Issues**
   - Verify network configuration
   - Check firewall status
   - Test connectivity

3. **Data Issues**
   - Check backup status
   - Verify RAID array health
   - Review system logs

## Common Tasks

### System Monitoring
```bash
# Check system resources
sudo ./scripts/system-monitor.sh

# Generate system report
sudo ./scripts/system-monitor.sh
# Select option 9

# Monitor in real-time
sudo ./scripts/system-monitor.sh
# Select option 10
```

### Network Management
```bash
# Change network settings
sudo ./scripts/network-config.sh

# Test network connectivity
ping -c 4 8.8.8.8
```

### Backup Operations
```bash
# Check backup status
sudo ./scripts/backup-manager.sh

# Run manual backup
sudo ./scripts/backup-manager.sh
# Select backup option
```

## Support and Documentation
- All scripts are located in the `/scripts` directory
- Documentation is available in the `/docs` directory
- System logs are in `/var/log`
- Backup logs are in `/var/log/backup.log`

## Important Notes
1. Always use `sudo` for administrative tasks
2. Keep SSH keys secure and backed up
3. Monitor system alerts regularly
4. Report issues to system administrators
5. Follow security protocols strictly

## Next Steps
1. Review all documentation in `/docs`
2. Familiarize yourself with the monitoring tools
3. Test backup and restore procedures
4. Set up monitoring alerts
5. Schedule regular maintenance checks 
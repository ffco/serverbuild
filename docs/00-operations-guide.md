# Dell R420 Server Operations Guide

## Table of Contents
1. [Overview](#overview)
2. [Server Specifications](#server-specifications)
3. [Key Features](#key-features)
4. [Access and Management](#access-and-management)
5. [Operational Considerations](#operational-considerations)
6. [Common Tasks](#common-tasks)
7. [Support and Documentation](#support-and-documentation)
8. [Storage Architecture](#storage-architecture)
9. [Docker Configuration Organization](#docker-configuration-organization)
10. [Emergency Procedures](#emergency-procedures)
11. [Next Steps](#next-steps)

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

## Storage Architecture

### Hardware Configuration
1. **System Storage**
   - 2x 250GB SSDs in RAID 1
   - Used for operating system and applications
   - Provides fast boot times and system operations
   - Redundant storage for system reliability

2. **Data Storage**
   - 2x 10TB spinning disk drives in RAID 1
   - Used for blockchain node data
   - Provides large storage capacity
   - Redundant storage for data safety

### Storage Management
1. **RAID Controller**
   - Dell PERC H710P Mini hardware RAID controller
   - Provides reliable storage management
   - Better performance than software RAID
   - Built-in monitoring and management

2. **Logical Volume Management (LVM)**
   - System drives partitioned using LVM
   - Provides flexible storage management
   - Allows easy partition resizing
   - Better organization of system storage

3. **Managing Storage Space Between Volumes**
   - **Prerequisites**:
     ```bash
     # Check current volume group space
     sudo vgs
     
     # List logical volumes and their sizes
     sudo lvs
     
     # Check filesystem usage
     df -h
     ```
   
   - **Moving Space Between Volumes**:
     1. **Identify Source and Target**:
        ```bash
        # Example: Moving space from /home to /var
        # First, check current sizes
        sudo lvs
        ```
     
     2. **Reduce Source Volume**:
        ```bash
        # Unmount the source volume if it's not root
        sudo umount /home
        
        # Check filesystem for errors
        sudo e2fsck -f /dev/ubuntu-vg/home
        
        # Resize the filesystem
        sudo resize2fs /dev/ubuntu-vg/home 80G
        
        # Reduce the logical volume
        sudo lvreduce -L 80G /dev/ubuntu-vg/home
        
        # Remount the volume
        sudo mount /home
        ```
     
     3. **Extend Target Volume**:
        ```bash
        # Extend the logical volume
        sudo lvextend -L +20G /dev/ubuntu-vg/var
        
        # Resize the filesystem
        sudo resize2fs /dev/ubuntu-vg/var
        ```
   
   - **Important Considerations**:
     1. **Safety First**:
        - Always backup data before resizing
        - Ensure enough free space in source volume
        - Check filesystem health before operations
     
     2. **Limitations**:
        - Cannot reduce below used space
        - Root volume requires special handling
        - Some filesystems may have size limits
     
     3. **Best Practices**:
        - Plan space allocation carefully
        - Monitor volume usage regularly
        - Keep some free space for emergencies
        - Document all storage changes
   
   - **Troubleshooting**:
     ```bash
     # If resize2fs fails
     sudo e2fsck -f /dev/ubuntu-vg/volume-name
     
     # Check filesystem type
     sudo blkid
     
     # View detailed volume information
     sudo lvdisplay
     ```

### Partition Layout
1. **System Drives (SSDs)**
   - `/boot`: 1GB (kernel and boot files)
   - `/`: 50GB (operating system)
   - `/home`: 100GB (user data)
   - `/var`: 100GB (system variable data)
   - `/var/lib/docker`: 50GB (container storage)
   - `swap`: 8GB (virtual memory)
     - For 64GB RAM, a smaller swap is sufficient
     - Used primarily for hibernation and memory pressure relief
     - Modern systems with large RAM rarely need extensive swap

2. **Data Drives (Spinning Disks)**
   - `/var/lib/chain`: 10TB (blockchain node data)
   - RAID 1 configuration for redundancy

### Storage Monitoring
1. **Health Monitoring**
   - SMART monitoring enabled
   - Daily short tests
   - Weekly long tests
   - Automated alerts for issues

2. **Performance Monitoring**
   - Disk I/O monitoring
   - Storage usage tracking
   - RAID array status
   - Space utilization alerts

### Backup Strategy
1. **System Backups**
   - Regular system state backups
   - Configuration backups
   - User data backups
   - Docker container backups

2. **Chain Data Backups**
   - Regular blockchain data backups
   - Node configuration backups

### Application Data Storage Guidelines

1. **System Drives (SSDs) - Fast Access Data**
   - **Recommended for**:
     - Application binaries and executables
     - Docker container images and configurations
     - System libraries and dependencies
     - Frequently accessed configuration files
     - Temporary files and caches
     - Log files that need fast access
   
   - **Location Examples**:
     ```bash
     /usr/local/bin/    # Application executables
     /var/lib/docker/   # Docker containers and images
     /var/cache/        # Application caches
     /var/log/          # System and application logs
     /etc/              # Configuration files
     ```

2. **Data Drives (Spinning Disks) - Large Data Storage**
   - **Recommended for**:
     - Database files and data
     - User uploads and content
     - Large media files
     - Archive data
     - Backup data
     - Blockchain node data
   
   - **Location Examples**:
     ```bash
     /var/lib/chain/    # Blockchain node data
     /var/lib/mysql/    # Database files
     /var/www/html/     # Web application data
     /data/            # General application data
     /archive/         # Archived data
     ```

3. **Best Practices**
   - **Performance Optimization**:
     - Keep frequently accessed files on SSDs
     - Use spinning disks for large, less frequently accessed data
     - Consider using symbolic links to manage data location
   
   - **Space Management**:
     - Monitor disk usage regularly
     - Set up alerts for space thresholds
     - Implement data retention policies
     - Use compression for archived data
   
   - **Backup Considerations**:
     - Back up both system and data drives
     - Implement different backup schedules for different data types
     - Keep backup data on separate physical drives
   
   - **Security**:
     - Set appropriate file permissions
     - Use separate user accounts for different applications
     - Implement access controls based on data sensitivity
     - Regular security audits of data locations

4. **Monitoring and Maintenance**
   ```bash
   # Check disk usage by directory
   sudo du -sh /* | sort -hr | head -n 20
   
   # Monitor I/O performance
   sudo iotop
   
   # Check filesystem health
   sudo smartctl -a /dev/sda
   
   # View detailed storage usage
   sudo df -h
   ```

5. **Migration Guidelines**
   - When moving data between drives:
     1. Ensure sufficient space in target location
     2. Use `rsync` for reliable data transfer
     3. Verify data integrity after migration
     4. Update application configurations if needed
     5. Test application functionality after migration

## Docker Configuration Organization

### Directory Structure
1. **Base Directory**
   - `/opt/docker` - Main directory for all Docker-related configurations
   - Contains subdirectories for different projects and services
   - Maintains separation of concerns and easy management

2. **Important Note: Docker Storage Locations**
   - `/var/lib/docker` - Default Docker root directory
     - Contains Docker's internal data (images, containers, volumes)
     - Managed by Docker daemon
     - Should not be modified directly
   - `/opt/docker` - Custom configuration directory
     - Contains our custom Docker configurations and project files
     - Used for organizing docker-compose files and project settings
     - Managed by system administrators
     - Separate from Docker's internal storage

3. **Initial Setup**
   ```bash
   # Create the base Docker directory structure
   sudo mkdir -p /opt/docker/{projects,common/{networks,volumes},scripts}
   
   # Set appropriate permissions
   sudo chown -R root:docker /opt/docker
   sudo chmod -R 750 /opt/docker
   
   # Create a basic README file
   sudo tee /opt/docker/README.md << 'EOF'
   # Docker Configuration Directory
   
   This directory contains all Docker-related configurations and projects.
   
   ## Directory Structure
   - projects/     : Individual project configurations
   - common/       : Shared configurations and templates
   - scripts/      : Docker-related utility scripts
   
   ## Usage
   - Place new project configurations in the projects/ directory
   - Use common/ for shared resources
   - Add utility scripts to scripts/
   EOF
   ```

4. **Project Organization**
   ```
   /opt/docker/
   ├── projects/           # Individual project directories
   │   ├── project1/      # First project
   │   │   ├── docker-compose.yml
   │   │   ├── .env
   │   │   └── config/    # Project-specific configurations
   │   └── project2/      # Second project
   │       ├── docker-compose.yml
   │       ├── .env
   │       └── config/
   ├── common/            # Shared configurations and templates
   │   ├── networks/      # Docker network configurations
   │   └── volumes/       # Shared volume definitions
   └── scripts/           # Docker-related utility scripts
   ```

### Configuration Files
1. **Docker Compose Files**
   - Store in project-specific directories
   - Use version 3.x for modern features
   - Include service definitions, networks, and volumes
   - Reference environment files for sensitive data

2. **Environment Files**
   - `.env` files for environment variables
   - Keep sensitive data separate from compose files
   - Use different files for development/production
   - Never commit sensitive data to version control

3. **Network Configurations**
   - Define custom networks in common directory
   - Use descriptive network names
   - Implement network isolation between projects
   - Document network topology

### Best Practices
1. **File Organization**
   - One project per directory
   - Keep configurations modular
   - Use consistent naming conventions
   - Maintain clear documentation

2. **Security**
   - Restrict access to configuration files
   - Use environment variables for secrets
   - Implement proper file permissions
   - Regular security audits

3. **Version Control**
   - Track configuration changes
   - Use meaningful commit messages
   - Maintain change history
   - Document major changes

### Maintenance
1. **Regular Tasks**
   - Review configuration files
   - Update documentation
   - Clean up unused configurations
   - Verify file permissions

2. **Backup Procedures**
   - Include configurations in backup strategy
   - Regular backup verification
   - Document restore procedures
   - Test configuration recovery

### Important Notes
1. **Configuration Management**
   - Keep configurations simple and clear
   - Document all custom settings
   - Maintain consistent formatting
   - Regular configuration reviews

2. **Access Control**
   - Limit access to configuration files
   - Use appropriate file permissions
   - Monitor access logs
   - Regular access reviews

3. **Directory Location**
   - `/opt` is the standard location for optional application software
   - Provides clean separation from system directories
   - Commonly used for third-party software and custom applications
   - Keeps system files separate from application configurations
   - Makes it easier to manage and backup application-specific data

## Emergency Procedures

### Critical System Failures
1. **Server Not Responding**
   - Check iDRAC for hardware status
   - Verify power status
   - Check network connectivity
   - Review system logs via iDRAC console

2. **Data Corruption**
   - Stop affected services
   - Check RAID array status
   - Verify backup integrity
   - Initiate restore from backup if needed

3. **Security Breach**
   - Disconnect from network if compromised
   - Review security logs
   - Check for unauthorized access
   - Contact security team

### Recovery Procedures
1. **System Recovery**
   ```bash
   # Check system logs
   sudo journalctl -n 100
   
   # Verify RAID status
   sudo mdadm --detail /dev/md0
   
   # Check disk health
   sudo smartctl -a /dev/sda
   ```

2. **Data Recovery**
   ```bash
   # Verify backup integrity
   sudo ./scripts/backup-manager.sh verify
   
   # Check filesystem integrity
   sudo fsck -f /dev/ubuntu-vg/volume-name
   ```

3. **Network Recovery**
   ```bash
   # Check network configuration
   sudo ./scripts/network-config.sh status
   
   # Verify firewall rules
   sudo ufw status
   ```

## Next Steps
1. **Initial Setup**
   - Review all documentation in `/docs`
   - Familiarize yourself with the monitoring tools
   - Test backup and restore procedures
   - Set up monitoring alerts
   - Schedule regular maintenance checks

2. **Ongoing Maintenance**
   - Perform regular system updates
   - Monitor system health
   - Review security logs
   - Test backup procedures
   - Update documentation as needed

3. **Documentation Updates**
   - Keep track of configuration changes
   - Document any custom procedures
   - Update troubleshooting guides
   - Maintain contact information
   - Review and update security protocols

4. **Training and Knowledge Transfer**
   - Document common procedures
   - Create runbooks for critical operations
   - Maintain a knowledge base
   - Schedule regular team reviews
   - Update procedures based on lessons learned 
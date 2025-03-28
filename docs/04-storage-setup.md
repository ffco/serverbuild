# Storage Configuration Guide

This guide covers the configuration of storage systems for your Dell R420 server, including RAID setup and backup configuration.

## Pre-Installation RAID Setup

### PERC H710P Mini RAID Configuration
# The PERC H710P Mini is Dell's hardware RAID controller that provides reliable storage management
# and better performance than software RAID solutions.

#### Accessing RAID Configuration
1. During server boot, press `Ctrl+R` when prompted to enter the PERC H710P Mini configuration
   # This must be done before OS installation to set up the storage foundation
2. Wait for the RAID controller to initialize
   # The controller needs time to detect and prepare all connected drives
3. The RAID configuration utility will load
   # This provides a text-based interface for RAID management

#### Creating RAID Arrays

##### System Drives (SSDs)
# Using SSDs for system drives provides fast boot times and quick system operations
# RAID 1 provides redundancy in case of drive failure

1. **Select Physical Disks**
   - Navigate to the physical disk view
   - Select both 250GB SSDs
   - Press `F2` to open the operation menu
   # This identifies the drives that will form the system array

2. **Create RAID 1 Array**
   - Choose "Create New VD" (Virtual Disk)
   - Select RAID Level: RAID 1
   - Set Stripe Size: 64KB
   - Set Read Ahead: Enabled
   - Set Write Back: Disabled (for data safety)
   - Set Disk Cache Policy: Disabled
   - Press `C` to confirm creation
   # RAID 1 mirrors data for redundancy
   # Disabled write back ensures data safety in case of power loss
   # Disabled disk cache prevents potential data corruption

3. **Initialize the Array**
   - Select the newly created virtual disk
   - Press `F2` and choose "Initialization"
   - Select "Fast Init" for quick initialization
   - Wait for initialization to complete
   # Fast initialization is sufficient for new drives
   # This prepares the drives for use

##### Backup Drives (Spinning Disks)
# Using spinning disks for backup provides large storage capacity at lower cost
# RAID 1 ensures backup data redundancy

1. **Select Physical Disks**
   - Navigate to the physical disk view
   - Select both 10TB spinning disk drives
   - Press `F2` to open the operation menu
   # These drives will store Bitcoin Core blockchain data and backups

2. **Create RAID 1 Array**
   - Choose "Create New VD"
   - Select RAID Level: RAID 1
   - Set Stripe Size: 64KB
   - Set Read Ahead: Enabled
   - Set Write Back: Disabled
   - Set Disk Cache Policy: Disabled
   - Press `C` to confirm creation
   # Same settings as system drives for consistency
   # Write back disabled for data safety

3. **Initialize the Array**
   - Select the newly created virtual disk
   - Press `F2` and choose "Initialization"
   - Select "Fast Init"
   - Wait for initialization to complete
   # Fast initialization is sufficient for new drives

#### Verifying Configuration
1. **Check Array Status**
   - View virtual disk properties
   - Verify RAID level is correct
   - Check array state is "Optimal"
   - Verify disk cache settings
   # Ensures arrays are properly configured and healthy

2. **Check Physical Disk Status**
   - Verify all disks are "Online"
   - Check for any warnings or errors
   - Verify disk speeds and capacities
   # Confirms all drives are properly detected and functioning

#### Important Notes
- Keep RAID configuration screenshots for documentation
- Note the virtual disk numbers assigned
- Document any custom settings
- Monitor array health regularly
- Set up alerts for array degradation

### Troubleshooting RAID Setup
If you encounter issues:
1. Check physical disk connections
2. Verify disk compatibility
3. Check for firmware updates
4. Review controller logs
5. Contact Dell support if needed

## Post-Installation Storage Configuration

### LVM Setup
# LVM provides flexible storage management allowing for easy resizing and management
# of partitions after installation

1. Create physical volumes:
   ```bash
   sudo pvcreate /dev/sda
   ```
   # Creates a physical volume from the RAID array
   # This is the foundation for LVM

2. Create volume group:
   ```bash
   sudo vgcreate vg0 /dev/sda
   ```
   # Creates a volume group to manage logical volumes
   # Named 'vg0' for simplicity

3. Create logical volumes:
   ```bash
   # Boot partition - Small size as it only needs to hold kernel and boot files
   sudo lvcreate -L 1G -n boot vg0
   
   # Root partition - Contains OS files
   sudo lvcreate -L 50G -n root vg0
   
   # Home partition - User data storage
   sudo lvcreate -L 100G -n home vg0
   
   # Var partition - System variable data
   sudo lvcreate -L 100G -n var vg0
   
   # Docker partition - Container storage
   sudo lvcreate -L 50G -n docker vg0
   
   # Swap partition - Virtual memory
   sudo lvcreate -L 16G -n swap vg0
   ```
   # Each volume is sized based on expected usage
   # Docker gets dedicated space for better performance

4. Format partitions:
   ```bash
   sudo mkfs.ext4 /dev/vg0/boot
   sudo mkfs.ext4 /dev/vg0/root
   sudo mkfs.ext4 /dev/vg0/home
   sudo mkfs.ext4 /dev/vg0/var
   sudo mkfs.ext4 /dev/vg0/docker
   sudo mkswap /dev/vg0/swap
   ```
   # ext4 is used for all partitions except swap
   # Provides good performance and reliability

5. Mount points:
   ```bash
   sudo mount /dev/vg0/root /mnt
   sudo mkdir -p /mnt/{boot,home,var,var/lib/docker}
   sudo mount /dev/vg0/boot /mnt/boot
   sudo mount /dev/vg0/home /mnt/home
   sudo mount /dev/vg0/var /mnt/var
   sudo mount /dev/vg0/docker /mnt/var/lib/docker
   ```
   # Sets up the directory structure for installation
   # Docker gets its own mount point for better isolation

6. Configure fstab:
   ```bash
   sudo nano /etc/fstab
   ```
   Add:
   ```text
   /dev/vg0/boot    /boot    ext4    defaults    0 2
   /dev/vg0/root    /        ext4    defaults    0 1
   /dev/vg0/home    /home    ext4    defaults    0 2
   /dev/vg0/var     /var     ext4    defaults    0 2
   /dev/vg0/docker  /var/lib/docker  ext4  defaults  0 2
   /dev/vg0/swap    none     swap    sw          0 0
   /dev/sdb         /var/lib/bitcoin ext4  defaults  0 2
   ```
   # Configures automatic mounting at boot
   # Numbers at the end indicate dump and fsck order

### Bitcoin Core Storage Setup
1. Create Bitcoin Core directory:
   ```bash
   sudo mkdir -p /var/lib/bitcoin
   sudo chown -R bitcoin:bitcoin /var/lib/bitcoin
   ```
   # Creates directory with proper permissions
   # Assumes 'bitcoin' user will run the node

2. Mount Bitcoin Core storage:
   ```bash
   sudo mount /dev/sdb /var/lib/bitcoin
   ```
   # Mounts the 10TB RAID array for blockchain storage

### Important Notes for Bitcoin Core Storage
1. **Storage Requirements**:
   - Bitcoin Core full node requires approximately 500GB+ of storage
   - Using 10TB spinning disks provides ample space for future growth
   - Consider enabling pruning if storage becomes an issue
   - Monitor blockchain growth regularly
   # Spinning disks chosen for capacity over speed
   # Pruning can help manage storage usage

2. **Performance Considerations**:
   - Spinning disks are slower than SSDs but provide more storage
   - Consider enabling Bitcoin Core's database cache
   - Regular maintenance can help optimize performance
   - Monitor I/O operations and adjust settings if needed
   # Cache settings can help mitigate slower disk speeds

3. **Backup Considerations**:
   - Bitcoin Core data is on RAID 1 array for redundancy
   - Consider additional backups for critical data
   - Document backup procedures
   - Test restore procedures regularly
   # RAID 1 provides basic redundancy
   # Additional backups recommended for critical data

4. **Monitoring Requirements**:
   - Monitor storage usage regularly
   - Set up alerts for storage thresholds
   - Keep track of blockchain growth
   - Monitor disk health and performance
   # Regular monitoring helps prevent issues

### Backup Storage Setup
1. Configure backup drives:
   ```bash
   # Create filesystem on backup RAID array
   sudo mkfs.ext4 /dev/sdb
   ```

2. Create backup mount point:
   ```bash
   sudo mkdir -p /backup
   sudo mount /dev/sdb /backup
   ```

## Monitoring Setup
1. Install monitoring tools:
   ```bash
   sudo apt install -y \
     smartmontools \
     iotop \
     htop
   ```
   # Tools for monitoring disk health and performance

2. Configure SMART monitoring:
   ```bash
   sudo smartctl -a /dev/sda
   sudo smartctl -a /dev/sdb
   ```
   # Checks disk health status

3. Set up disk monitoring:
   ```bash
   sudo nano /etc/smartd.conf
   ```
   Add:
   ```text
   DEVICESCAN -d auto -n never -a -s (S/../.././02|L/../../6/03)
   ```
   # Configures automatic disk health monitoring
   # Runs short test daily, long test weekly

## Verification
1. Check RAID status:
   ```bash
   sudo lspci | grep RAID
   sudo lsscsi
   ```
   # Verifies RAID controller and array status

2. Verify LVM setup:
   ```bash
   sudo pvs
   sudo vgs
   sudo lvs
   ```
   # Confirms LVM configuration is correct

## Next Steps
After completing storage setup, proceed to the [Network Configuration](06-network-setup.md) guide.

## Notes
- Regular backup testing
- Monitor disk health
- Keep RAID status logs
- Document storage layout

## 4. Configure Mount Points

### System Drives (SSDs)
```bash
# Create mount points
sudo mkdir -p /boot
sudo mkdir -p /home
sudo mkdir -p /var/lib/docker

# Configure fstab
sudo nano /etc/fstab
```

Add the following lines:
```
/dev/mapper/vg0-boot /boot ext4 defaults 0 2
/dev/mapper/vg0-root / ext4 defaults 0 1
/dev/mapper/vg0-home /home ext4 defaults 0 2
/dev/mapper/vg0-var /var ext4 defaults 0 2
/dev/mapper/vg0-docker /var/lib/docker ext4 defaults 0 2
swap swap defaults 0 0
```

### Data Drives (Spinning Disks)
```bash
# Create chain data directory
sudo mkdir -p /var/lib/chain

# Configure fstab
sudo nano /etc/fstab
```

Add the following line:
```
/dev/sdb /var/lib/chain ext4 defaults 0 2
```

### Set Permissions
```bash
# Set appropriate permissions
sudo chown -R chain:chain /var/lib/chain
sudo chmod 750 /var/lib/chain
```

## 5. Important Notes

### Storage Requirements
- Chain node requires significant storage (500GB+)
- Regular pruning recommended
- Monitor storage usage
- Keep sufficient free space

### Performance Considerations
- Spinning disks provide adequate performance
- Enable node database cache
- Regular maintenance recommended
- Monitor I/O patterns

### Backup Strategy
- Regular chain data backups
- Node configuration backups
- Wallet backups
- Test restore procedures

### Monitoring
- Monitor storage usage
- Check disk health
- Track I/O performance
- Set up alerts 
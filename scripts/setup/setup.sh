#!/bin/bash

# Dell R420 Server Setup Script
# This script automates the setup process for a Dell R420 server running Ubuntu Server LTS

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

# Function to check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Ubuntu version
    if ! lsb_release -a | grep -q "Ubuntu"; then
        print_error "This script is designed for Ubuntu Server"
        exit 1
    fi
    
    # Check disk configuration
    if ! lsblk | grep -q "md0"; then
        print_warning "RAID array not detected. Please ensure RAID is configured first."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to update system
update_system() {
    print_status "Updating system..."
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        ufw \
        fail2ban \
        htop \
        iotop \
        smartmontools \
        mdadm \
        lvm2 \
        rsnapshot \
        borgbackup \
        duplicity \
        restic \
        prometheus-node-exporter \
        grafana
}

# Function to configure security
configure_security() {
    print_status "Configuring security..."
    
    # Configure UFW
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw --force enable
    
    # Configure fail2ban
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 3
EOF
    systemctl enable fail2ban
    systemctl start fail2ban
}

# Function to configure storage
configure_storage() {
    print_status "Configuring storage..."
    
    # Create backup directory
    mkdir -p /backup/{system,config,data}
    chmod 700 /backup
    
    # Configure fstab
    cat >> /etc/fstab << EOF
/dev/vg0/boot    /boot    ext4    defaults    0 2
/dev/vg0/root    /        ext4    defaults    0 1
/dev/vg0/home    /home    ext4    defaults    0 2
/dev/vg0/var     /var     ext4    defaults    0 2
/dev/vg0/swap    none     swap    sw          0 0
/dev/md1         /backup  ext4    defaults    0 2
EOF
}

# Function to configure backup system
configure_backup() {
    print_status "Configuring backup system..."
    
    # Configure rsnapshot
    cp /etc/rsnapshot.conf /etc/rsnapshot.conf.local
    cat > /etc/rsnapshot.conf.local << EOF
snapshot_root   /backup/system/rsnapshot/
retain          hourly  6
retain          daily   7
retain          weekly  4
retain          monthly 3

backup          /etc/           localhost/
backup          /home/          localhost/
backup          /var/           localhost/
backup          /usr/local/     localhost/
EOF
    
    # Create backup scripts
    cat > /usr/local/bin/backup.sh << 'EOF'
#!/bin/bash
rsnapshot hourly
EOF
    chmod +x /usr/local/bin/backup.sh
    
    # Configure cron job
    (crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/backup.sh") | crontab -
}

# Function to configure monitoring
configure_monitoring() {
    print_status "Configuring monitoring..."
    
    # Configure prometheus node exporter
    systemctl enable prometheus-node-exporter
    systemctl start prometheus-node-exporter
    
    # Configure Grafana
    systemctl enable grafana-server
    systemctl start grafana-server
}

# Main setup function
main() {
    print_status "Starting Dell R420 Server Setup..."
    
    check_root
    check_requirements
    update_system
    configure_security
    configure_storage
    configure_backup
    configure_monitoring
    
    print_status "Setup completed successfully!"
    print_warning "Please review the documentation in /docs for additional configuration steps."
}

# Run main function
main 
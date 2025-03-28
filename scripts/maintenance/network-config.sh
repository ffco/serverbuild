#!/bin/bash

# Network Configuration Script for Dell R420 Server
# This script helps manage network configuration changes

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

# Function to backup current network configuration
backup_network_config() {
    print_status "Backing up current network configuration..."
    cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup
}

# Function to restore network configuration
restore_network_config() {
    print_status "Restoring network configuration..."
    cp /etc/netplan/01-netcfg.yaml.backup /etc/netplan/01-netcfg.yaml
    netplan apply
}

# Function to get current network configuration
get_current_config() {
    print_status "Current network configuration:"
    cat /etc/netplan/01-netcfg.yaml
}

# Function to change network configuration
change_network_config() {
    print_status "Changing network configuration..."
    
    # Get new configuration from user
    read -p "Enter new IP address: " new_ip
    read -p "Enter new subnet mask (e.g., 24): " new_mask
    read -p "Enter new gateway: " new_gateway
    read -p "Enter new DNS servers (comma-separated): " new_dns
    
    # Backup current configuration
    backup_network_config
    
    # Create new configuration
    cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      addresses:
        - ${new_ip}/${new_mask}
      gateway4: ${new_gateway}
      nameservers:
        addresses: [${new_dns}]
EOF
    
    # Apply new configuration
    netplan apply
    
    # Verify new configuration
    print_status "Verifying new network configuration..."
    ip addr show
    ip route
    ping -c 4 ${new_gateway}
}

# Function to test network connectivity
test_connectivity() {
    print_status "Testing network connectivity..."
    
    # Test DNS resolution
    print_status "Testing DNS resolution..."
    nslookup google.com
    
    # Test internet connectivity
    print_status "Testing internet connectivity..."
    ping -c 4 8.8.8.8
    
    # Test gateway connectivity
    print_status "Testing gateway connectivity..."
    gateway=$(ip route | grep default | awk '{print $3}')
    ping -c 4 ${gateway}
}

# Function to show network status
show_network_status() {
    print_status "Current network status:"
    echo -e "\nNetwork Interfaces:"
    ip link show
    
    echo -e "\nIP Addresses:"
    ip addr show
    
    echo -e "\nRouting Table:"
    ip route
    
    echo -e "\nDNS Configuration:"
    cat /etc/resolv.conf
}

# Function to configure firewall rules
configure_firewall() {
    print_status "Configuring firewall rules..."
    
    # Allow SSH
    ufw allow ssh
    
    # Allow HTTP/HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Enable firewall
    ufw --force enable
    
    # Show firewall status
    ufw status verbose
}

# Main menu function
show_menu() {
    echo -e "\nNetwork Configuration Menu:"
    echo "1. Show current network status"
    echo "2. Change network configuration"
    echo "3. Test network connectivity"
    echo "4. Configure firewall rules"
    echo "5. Restore previous configuration"
    echo "6. Exit"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            show_network_status
            ;;
        2)
            change_network_config
            ;;
        3)
            test_connectivity
            ;;
        4)
            configure_firewall
            ;;
        5)
            restore_network_config
            ;;
        6)
            print_status "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    echo
    show_menu
}

# Main function
main() {
    print_status "Starting Network Configuration Tool..."
    
    check_root
    
    # Show initial network status
    show_network_status
    
    # Show menu
    show_menu
}

# Run main function
main 
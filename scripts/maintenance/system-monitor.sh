#!/bin/bash

# System Monitoring Script for Dell R420 Server
# This script helps monitor system health and perform maintenance tasks
# It provides a menu-driven interface to check various aspects of the system
# and perform routine maintenance tasks.

# Exit on error - this ensures the script stops if any command fails
set -e

# Color definitions for better visual feedback
RED='\033[0;31m'    # Used for error messages
GREEN='\033[0;32m'  # Used for success messages
YELLOW='\033[1;33m' # Used for warnings
NC='\033[0m'        # No Color - used to reset color

# Function to print colored output for status messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Function to print colored output for error messages
print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to print colored output for warning messages
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to check if running as root
# Many system monitoring commands require root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root"
        exit 1
    fi
}

# Function to check system resources
# Shows CPU, memory, disk usage, and top processes
check_resources() {
    print_status "Checking system resources..."
    
    # Show CPU usage statistics for 5 seconds
    echo -e "\nCPU Usage:"
    mpstat 1 5
    
    # Show memory usage in megabytes
    echo -e "\nMemory Usage:"
    free -m
    
    # Show disk usage in human-readable format
    echo -e "\nDisk Usage:"
    df -h
    
    # Show top 10 processes by CPU usage
    echo -e "\nTop Processes:"
    ps aux --sort=-%cpu | head -n 10
}

# Function to check disk health using SMART
# Checks both system SSDs and backup drives
check_disk_health() {
    print_status "Checking disk health..."
    
    # Check system SSDs (sda and sdb)
    for disk in /dev/sda /dev/sdb; do
        echo -e "\nChecking $disk:"
        smartctl -a $disk
    done
    
    # Check backup drives (sdc and sdd)
    for disk in /dev/sdc /dev/sdd; do
        echo -e "\nChecking $disk:"
        smartctl -a $disk
    done
}

# Function to check RAID status
# Shows detailed information about RAID arrays and their sync status
check_raid_status() {
    print_status "Checking RAID status..."
    
    # Show detailed information about RAID arrays
    echo -e "\nRAID Array Status:"
    mdadm --detail /dev/md0
    mdadm --detail /dev/md1
    
    # Show current RAID sync status
    echo -e "\nRAID Sync Status:"
    cat /proc/mdstat
}

# Function to check network status
# Shows network interfaces, connections, and usage
check_network_status() {
    print_status "Checking network status..."
    
    # Show all network interfaces
    echo -e "\nNetwork Interfaces:"
    ip link show
    
    # Show listening ports and network connections
    echo -e "\nNetwork Connections:"
    netstat -tuln
    
    # Show network usage for 10 seconds
    echo -e "\nNetwork Usage:"
    iftop -t -s 10
}

# Function to check system logs
# Shows recent entries from various log files
check_logs() {
    print_status "Checking system logs..."
    
    # Show recent system logs
    echo -e "\nRecent System Logs:"
    journalctl -n 100
    
    # Show recent authentication logs
    echo -e "\nRecent Auth Logs:"
    tail -n 50 /var/log/auth.log
    
    # Show recent kernel logs
    echo -e "\nRecent Kernel Logs:"
    dmesg | tail -n 50
}

# Function to check security status
# Shows firewall status, failed login attempts, and open ports
check_security() {
    print_status "Checking security status..."
    
    # Show firewall status and rules
    echo -e "\nFirewall Status:"
    ufw status verbose
    
    # Show recent failed login attempts
    echo -e "\nFailed Login Attempts:"
    grep "Failed password" /var/log/auth.log | tail -n 10
    
    # Show all listening ports
    echo -e "\nOpen Ports:"
    netstat -tuln
}

# Function to perform system maintenance
# Updates system, cleans old packages and logs, checks filesystems
perform_maintenance() {
    print_status "Performing system maintenance..."
    
    # Update package lists and upgrade packages
    apt-get update
    apt-get upgrade -y
    
    # Remove unused packages and clean package cache
    apt-get autoremove -y
    apt-get clean
    
    # Remove logs older than 7 days
    journalctl --vacuum-time=7d
    
    # Clean temporary files
    rm -rf /tmp/*
    rm -rf /var/tmp/*
    
    # Check filesystem integrity
    fsck -f /dev/vg0/root
    fsck -f /dev/vg0/home
    fsck -f /dev/vg0/var
}

# Function to check backup status
# Shows backup space usage and recent backup information
check_backup_status() {
    print_status "Checking backup status..."
    
    # Show backup drive space usage
    echo -e "\nBackup Space Usage:"
    df -h /backup
    
    # Show recent backup files
    echo -e "\nRecent Backups:"
    ls -l /backup/system/rsnapshot/
    
    # Show recent backup logs
    echo -e "\nBackup Logs:"
    tail -n 50 /var/log/backup.log
}

# Function to generate system report
# Creates a comprehensive report of system status
generate_report() {
    print_status "Generating system report..."
    
    # Create report file with timestamp
    REPORT_FILE="/var/log/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Generate report with various system information
    {
        echo "System Report - $(date)"
        echo "====================="
        echo
        
        # System resources section
        echo "System Resources:"
        echo "----------------"
        free -m
        echo
        
        # Disk usage section
        echo "Disk Usage:"
        echo "-----------"
        df -h
        echo
        
        # RAID status section
        echo "RAID Status:"
        echo "------------"
        mdadm --detail /dev/md0
        echo
        
        # Network status section
        echo "Network Status:"
        echo "---------------"
        ip addr show
        echo
        
        # Security status section
        echo "Security Status:"
        echo "----------------"
        ufw status verbose
        echo
        
        # Recent logs section
        echo "Recent Logs:"
        echo "------------"
        journalctl -n 50
    } > $REPORT_FILE
    
    print_status "Report generated: $REPORT_FILE"
}

# Function to monitor system in real-time
# Shows live updates of system resources
monitor_realtime() {
    print_status "Starting real-time monitoring..."
    print_warning "Press Ctrl+C to stop monitoring"
    
    # Use watch command to update display every second
    watch -n 1 '
    echo "CPU Usage:"
    mpstat 1 1 | tail -n 1
    echo
    echo "Memory Usage:"
    free -m | grep Mem
    echo
    echo "Disk I/O:"
    iostat -x 1 1 | tail -n 2
    echo
    echo "Network Usage:"
    ifconfig | grep RX
    '
}

# Main menu function
# Displays available options and handles user input
show_menu() {
    echo -e "\nSystem Monitoring Menu:"
    echo "1. Check system resources"
    echo "2. Check disk health"
    echo "3. Check RAID status"
    echo "4. Check network status"
    echo "5. Check system logs"
    echo "6. Check security status"
    echo "7. Perform maintenance"
    echo "8. Check backup status"
    echo "9. Generate system report"
    echo "10. Monitor system in real-time"
    echo "11. Exit"
    
    read -p "Enter your choice (1-11): " choice
    
    # Handle user menu selection
    case $choice in
        1)
            check_resources
            ;;
        2)
            check_disk_health
            ;;
        3)
            check_raid_status
            ;;
        4)
            check_network_status
            ;;
        5)
            check_logs
            ;;
        6)
            check_security
            ;;
        7)
            perform_maintenance
            ;;
        8)
            check_backup_status
            ;;
        9)
            generate_report
            ;;
        10)
            monitor_realtime
            ;;
        11)
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
# Initializes the script and starts the menu
main() {
    print_status "Starting System Monitoring Tool..."
    
    # Check for root privileges
    check_root
    
    # Show initial system status
    check_resources
    
    # Show menu
    show_menu
}

# Run main function
main 
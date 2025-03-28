# Initial Server Setup

This guide covers the initial steps required to prepare your Dell R420 server for Ubuntu Server installation.

## Prerequisites
- Dell R420 server
- USB drive (8GB or larger) for Ubuntu Server installation
- Ethernet cable for network connection
- Monitor and keyboard for initial setup
- Power source

## Physical Setup
1. Place the server in a well-ventilated area
2. Connect the following:
   - Power cable
   - Ethernet cable to the primary network port
   - Monitor and keyboard
3. Power on the server

## BIOS Setup
1. During boot, press F2 to enter BIOS setup
2. Configure the following settings:
   - Set boot mode to UEFI
   - Disable legacy boot options
   - Enable virtualization support
   - Set boot order to prioritize USB devices
3. Save changes and exit BIOS

## iDRAC Setup
1. **Initial Connection**
   - Connect to the iDRAC port using an Ethernet cable
   - Default IP address: 192.168.0.120
   - Access iDRAC web interface:
     - Open a web browser
     - Navigate to: https://192.168.0.120
     - Accept the SSL certificate warning

2. **Default Access**
   - Username: root
   - Password: calvin
   - **IMPORTANT**: Change these credentials immediately

3. **Security Configuration**
   - Go to iDRAC Settings > Users
   - Select root user
   - Click "Change Password"
   - Enter and confirm new secure password
   - Document the new credentials securely

4. **Network Configuration**
   - Set static IP or DHCP as needed
   - Update DNS settings
   - Configure NTP servers
   - Test network connectivity

5. **Additional Settings**
   - Configure email alerts (optional)
   - Set up SNMP monitoring (optional)
   - Configure power management
   - Set up remote console access

## Next Steps
After completing these steps, proceed to the [OS Installation](02-os-installation.md) guide for Ubuntu Server installation instructions.

## Troubleshooting
If you encounter any issues:
1. Check all physical connections
2. Verify power supply is functioning
3. Ensure monitor and keyboard are properly connected
4. Check network cable connection
5. Verify iDRAC network settings
6. Try accessing iDRAC using the default IP
7. Check for any error messages in the iDRAC interface

## Notes
- Keep the default iDRAC credentials secure
- Document any custom BIOS settings
- Note the server's physical location and network configuration
- Store iDRAC credentials securely
- Document any custom iDRAC settings 
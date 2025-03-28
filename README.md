# Dell R420 Server Setup Guide

This repository contains scripts and configuration files for setting up a Dell R420 server running Ubuntu Server LTS. The setup is designed for hosting sensitive information and future Docker-based projects.

## Hardware Specifications
- Server: Dell R420
- Storage:
  - 2x 250GB SSDs (Primary storage)
  - 2x 10TB Spinning disk drives (Backup storage)
- iDRAC for remote management
- Ubuntu Server LTS (No GUI)

## Repository Structure
```
.
├── docs/           # Documentation files
├── configs/        # Configuration templates
├── scripts/        # Setup and maintenance scripts
└── README.md       # This file
```

## Getting Started

1. Clone this repository on your server:
   ```bash
   git clone https://github.com/yourusername/r410-server-setup.git
   cd r410-server-setup
   ```

2. Follow the setup instructions in the following order:
   - [Initial Server Setup](docs/01-initial-setup.md)
   - [iDRAC Configuration](docs/02-idrac-setup.md)
   - [Operating System Installation](docs/03-os-installation.md)
   - [Security Configuration](docs/04-security-setup.md)
   - [Storage Configuration](docs/05-storage-setup.md)
   - [Network Configuration](docs/06-network-setup.md)
   - [Backup System Setup](docs/07-backup-setup.md)
   - [Maintenance Procedures](docs/08-maintenance.md)

## Security Notice
This server is designed to be deployed on the public internet. All configurations prioritize security and follow best practices for server hardening.
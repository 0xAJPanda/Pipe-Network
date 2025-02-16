# Pipe Network DevNet Node Installer

A **single-run bash script** to quickly install and configure a Pipe DevNet 2 node. This script creates a systemd service named `pipe`, automatically sets up the node binary, and includes a hardcoded referral code for the DevNet phase.

---

## Overview

- **One-time installation script**: No interactive menus beyond prompting for Solana address, RAM, and disk sizes.
- **Solana wallet address check** (must be 44 characters).
- Creates `/root/pipe` (for the binary and config) and `/root/pipe/download_cache` (for caching).
- Installs a systemd service named `pipe` (enabled by default).
- Node logs can be viewed via `journalctl -u pipe -f`.
- During the install feel free to use my ref code : 6e458aff4833b08d

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
   - [Service Management](#service-management)
   - [Checking Node Status](#checking-node-status)
   - [Logs](#logs)
   - [Backup](#backup)
5. [Troubleshooting](#troubleshooting)
6. [Support](#support)

---

## Installation

1. **Download** or **copy** the installer script (e.g., `pipe_installer.sh`) to your server and make it executable:

```bash
   git clone https://github.com/0xAJPanda/Pipe-Network.git
```

```bash
cd Pipe-Network && chmod +x pipe-manager.sh
```

Run it as root or with sudo:

```bash
sudo ./pipe_manager.sh
```

You'll be prompted for:

- Solana address (44 characters, base58)
- RAM in GB (default: 4GB)
- Disk in GB (default: 100GB)

The script will:

- Create `/root/pipe` and `/root/pipe/download_cache`
- Download the Pop binary into `/root/pipe`
- Generate `/etc/systemd/system/pipe.service`
- Enable and start the pipe service

---

## Usage

The script provides an interactive menu with the following options:

1. Install/Start/Stop node
2. Show status
3. Generate referral code
4. Backup node
5. Update node
6. Configure node
7. Uninstall node
8. Exit

### Initial Setup

During the first installation, you'll need to provide:

- Your Solana wallet address
- RAM allocation (default: 8GB)
- Disk space allocation (default: 200GB)
- Cache directory location
- Referral code (optional)

### Configuration

You can modify your node's configuration at any time using option 6:

- Change Solana wallet address
- Adjust RAM allocation
- Modify disk space allocation
- Update cache directory location

### Service Management

Since the node is installed as a systemd service named `pipe`, you can manage it with:

```bash
sudo systemctl stop pipe
sudo systemctl start pipe
sudo systemctl restart pipe
sudo systemctl status pipe
```

### Checking Node Status

Check your node's reputation and scores at any time:

```bash
cd /root/pipe
./pop --status
```

This will show details about uptime, egress, and historical scores.

### Logs

To view the logs in real-time:

```bash
journalctl -u pipe -f -n 10
```

### Backup

The file `/root/pipe/node_info.json` is tied to your IP address. If you lose `node_info.json`, you cannot restore the same node on this IP. It's recommended to keep a backup of it in a safe place.

### Troubleshooting

Check if the service is running:

```bash
systemctl status pipe
```

View logs:

```bash
journalctl -u pipe -f
```

Reinstalling the node may require removing `/root/pipe/node_info.json` and the `/etc/systemd/system/pipe.service` if you want a fully clean setup.

---

## Support

- For Pipe Network questions, refer to **Pipe Documentation**.
- For issues with this installer script, open an issue or pull request on the relevant GitHub repository.

---

This markdown document provides a structured overview of the installation process and related information in a clear and organized format.

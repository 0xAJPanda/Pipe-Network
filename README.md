## Authors

KrimDev + AJPanda
I am just adding some extra sauce to it!

# Pipe DevNet 2 Node Manager

A bash script to manage Pipe DevNet 2 nodes easily. This script provides a user-friendly interface to install, configure, and manage your Pipe node.

## Features

- Easy installation and configuration
- Referral code support during installation
- Solana wallet address validation
- Configurable RAM and disk space allocation
- Custom cache directory support
- Node status monitoring
- Service management (start/stop)
- Backup management
- Easy uninstallation
- Referral code generation

## Requirements

- Linux operating system
- Sudo privileges
- Minimum 4GB RAM
- At least 100GB free disk space
- Internet connectivity available 24/7

## Installation

1. Download the script make executable and run.
```bash
wget https://raw.githubusercontent.com/0xAJPanda/Pipe-Network//main/pipe-manager.sh && chmod +x pipe-manager.sh && ./pipe-manager.sh
```

## Usage

The script provides an interactive menu with the following options:

1. Install
2. Show status
3. Generate referral code
4. Backup node to your directory
5. Update node
6. Reconfigure node
7. Uninstall node
8. Exit Script

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

The node runs as a systemd service for reliability. The script manages this automatically, but you can also manually control it:
```bash
sudo systemctl start pop.service
sudo systemctl stop pop.service
sudo systemctl status pop.service
```

### Logs

View node logs using:
```bash
sudo journalctl -u pop.service  -f -n 10
```

### Backup

The script automatically creates backups of your node_info.json file during important operations. Backups are stored in your home directory with timestamps.

## Support

For issues with the script, please open an issue on GitHub.

For Pipe Network related questions, visit:
- [Dashboard](https://dashboard.pipenetwork.com/node-lookup)
- [Official Documentation](https://docs.pipe.network/)

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

MIT License - see the [LICENSE.md](LICENSE.md) file for details

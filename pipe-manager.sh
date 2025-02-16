#!/usr/bin/env bash

###############################################################################
# Pipe Network Devnet-2 Node Setup Script (No old-service instructions)
#
# - Installs and configures Pipe node in /root/pipe
# - Creates a systemd service named 'pipe'
# ###############################################################################

set -e

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

POP_VERSION="v0.2.5"
DOWNLOAD_URL="https://dl.pipecdn.app/${POP_VERSION}/pop"
PIPE_DIR="/root/pipe"
CACHE_DIR="${PIPE_DIR}/download_cache"
SERVICE_FILE="/etc/systemd/system/pipe.service"

# Default settings
DEFAULT_RAM=8
DEFAULT_DISK=200

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}   Pipe Network Devnet-2 Node Setup Script${NC}"
echo -e "${BLUE}================================================================${NC}"
echo

# 1) Create directories
echo -e "${BLUE}[1/5] Creating directories...${NC}"
mkdir -p "${PIPE_DIR}"
mkdir -p "${CACHE_DIR}"
cd "${PIPE_DIR}"

# 2) Download Pipe binary
echo -e "${BLUE}[2/5] Downloading Pipe binary (${POP_VERSION})...${NC}"
curl -L -o pop "${DOWNLOAD_URL}"
chmod +x pop

# 3) Gather user inputs
echo
echo -e "${BLUE}Configuration for your Pipe Node:${NC}"
read -p "Enter your Solana address (44-char base58): " SOLANA_ADDRESS

while [[ $(echo -n "$SOLANA_ADDRESS" | wc -c) -ne 44 ]]; do
  echo -e "${RED}Invalid Solana address (must be 44 chars). Try again.${NC}"
  read -p "Enter your Solana address (44-char base58): " SOLANA_ADDRESS
done

read -p "Enter RAM size in GB [default: ${DEFAULT_RAM}]: " RAM_SIZE
RAM_SIZE=${RAM_SIZE:-$DEFAULT_RAM}

read -p "Enter disk size in GB [default: ${DEFAULT_DISK}]: " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-$DEFAULT_DISK}

# 4) Create systemd file
echo -e "${BLUE}[3/5] Creating systemd file at ${SERVICE_FILE}...${NC}"
sudo tee "${SERVICE_FILE}" > /dev/null << EOF
[Unit]
Description=Pipe Node Service
After=network.target
Wants=network-online.target

[Service]
User=root
Group=root
WorkingDirectory=${PIPE_DIR}
ExecStart=${PIPE_DIR}/pop \\
    --ram ${RAM_SIZE} \\
    --max-disk ${DISK_SIZE} \\
    --cache-dir ${CACHE_DIR} \\
    --pubKey ${SOLANA_ADDRESS} \\
    --signup-by-referral-route 90e87223b40eccd
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pipe-node

[Install]
WantedBy=multi-user.target
EOF

# 5) Start systemd
echo -e "${BLUE}[4/5] Enabling and starting 'pipe' service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable pipe
sudo systemctl start pipe

# Check status
echo -e "${BLUE}[5/5] Checking 'pipe' service status...${NC}"
sleep 2
if systemctl is-active --quiet pipe; then
  echo -e "${GREEN}Service 'pipe' is running successfully!${NC}"
else
  echo -e "${RED}Service 'pipe' failed to start. Check logs: journalctl -u pipe -f${NC}"
fi

echo
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN} Pipe Network Devnet-2 Node Setup Completed!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo
echo -e " \u2022 To check the service status, run:  ${YELLOW}systemctl status pipe${NC}"
echo -e " \u2022 To check node logs live, run:      ${YELLOW}journalctl -u pipe -f${NC}"
echo -e " \u2022 To check node status, run:         ${YELLOW}cd /root/pipe && ./pop --status${NC}"
echo
echo -e "${YELLOW}Important:${NC} Backup /root/pipe/node_info.json, as it is tied to this IP address."
echo -e "If you lose node_info.json, you cannot restore the same node on this IP."
echo
echo -e "${GREEN}Done!${NC}"

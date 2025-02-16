#!/bin/bash

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PINK='\033[0;35m'
NC='\033[0m'

# Default configuration
SOLANA_KEY_DEFAULT=""
POP_VERSION="v0.2.5"
DOWNLOAD_URL="https://dl.pipecdn.app/${POP_VERSION}/pop"
AUTHOR="KrimDev"
DEFAULT_RAM=4
DEFAULT_DISK=100
DEFAULT_CACHE_DIR="/root/pipe/download_cache"  # Changed to /root/pipe

# Configuration file
CONFIG_FILE="$HOME/.pipe_config"

# Create directories
mkdir -p /root/pipe
mkdir -p /root/pipe/download_cache/  # Changed to /root/pipe

# Get node_id
get_node_id() {
    if [ -f "/root/pipe/node_info.json" ]; then  # Changed to /root/pipe
        local node_id=$(grep -o '"node_id": *"[^"]*"' "/root/pipe/node_info.json" | cut -d'"' -f4)  # Changed to /root/pipe
        echo "$node_id"
    fi
}

# Validate Solana address
validate_solana_address() {
    local address="$1"
    
    # Remove all whitespace
    address=$(echo "$address" | tr -d '[:space:]')
    
    # Check if address is exactly 44 characters long and contains only valid base58 characters
    if [[ ${#address} -eq 44 && "$address" =~ ^[1-9A-HJ-NP-Za-km-z]+$ ]]; then
        echo "$address"
        return 0
    else
        echo "Invalid Solana address"
        return 1
    fi
}

# Load or create configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        RAM_SIZE=$DEFAULT_RAM
        DISK_SIZE=$DEFAULT_DISK
        CACHE_DIR=$DEFAULT_CACHE_DIR
        SOLANA_KEY=$SOLANA_KEY_DEFAULT
        save_config
    fi
}

# Save configuration
save_config() {
    echo "RAM_SIZE=$RAM_SIZE" > "$CONFIG_FILE"
    echo "DISK_SIZE=$DISK_SIZE" >> "$CONFIG_FILE"
    echo "CACHE_DIR=$CACHE_DIR" >> "$CONFIG_FILE"
    echo "SOLANA_KEY=$SOLANA_KEY" >> "$CONFIG_FILE"
}

# Create systemd service
create_service() {
    cat << EOF | sudo tee /etc/systemd/system/pipe.service  # Changed service name to pipe.service
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=pop-svc-user
Group=pop-svc-user
ExecStart=/root/pipe/pop \\
    --ram=${RAM_SIZE} \\
    --pubKey ${SOLANA_KEY} \\
    --max-disk ${DISK_SIZE} \\
    --cache-dir ${CACHE_DIR} \\
    --signup-by-referral-route ${referral_code}
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pop-node
WorkingDirectory=/root/pipe  # Changed to /root/pipe

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable pipe.service  # Changed service name to pipe.service
    sudo systemctl start pipe.service   # Changed service name to pipe.service
}

# Check if node is installed
check_installation() {
    if [ -f "/root/pipe/pop" ] && [ -f "/root/pipe/node_info.json" ]; then  # Changed to /root/pipe
        if grep -q "token" "/root/pipe/node_info.json"; then  # Changed to /root/pipe
            export NODE_REGISTERED=true
            return 0
        else
            export NODE_REGISTERED=false
            return 0
        fi
    else
        export NODE_REGISTERED=false
        return 1
    fi
}

# Check if node is running
check_running() {
    if systemctl is-active --quiet pipe.service; then  # Changed service name to pipe.service
        return 0
    else
        return 1
    fi
}

# Show node status
show_status() {
    echo -e "${BLUE}Node Status:${NC}"
    cd /root/pipe && /root/pipe/pop --status  # Changed to /root/pipe
}

# Generate referral code
generate_referral() {
    echo -e "${BLUE}Generating referral code:${NC}"
    cd /root/pipe && /root/pipe/pop --gen-referral-route  # Changed to /root/pipe
}

# Backup node
backup_node() {
    BACKUP_FILE="node_info.backup-$(date +%Y-%m-%d)"
    cp /root/pipe/node_info.json ~/$BACKUP_FILE  # Changed to /root/pipe
    echo -e "${GREEN}Backup created: ~/$BACKUP_FILE${NC}"
}

# Update node
update_node() {
    echo -e "${BLUE}Updating node...${NC}"
    cd /root/pipe && /root/pipe/pop --refresh  # Changed to /root/pipe
    echo -e "${GREEN}Update completed!${NC}"
}

# Uninstall node
uninstall_node() {
    echo -e "${RED}=== Uninstalling Pipe DevNet 2 Node ===${NC}"
    echo -e "${YELLOW}Warning: This will remove all node files and configurations!${NC}"
    read -p "Are you sure you want to uninstall the node? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Stopping node service...${NC}"
        sudo systemctl stop pipe.service 2>/dev/null  # Changed service name to pipe.service
        sudo systemctl disable pipe.service 2>/dev/null  # Changed service name to pipe.service
        
        echo -e "${BLUE}Removing service file...${NC}"
        sudo rm -f /etc/systemd/system/pipe.service  # Changed service name to pipe.service
        sudo systemctl daemon-reload
        
        echo -e "${BLUE}Backing up node_info.json...${NC}"
        if [ -f "/root/pipe/node_info.json" ]; then  # Changed to /root/pipe
            cp /root/pipe/node_info.json "$HOME/node_info.backup-$(date +%Y%m%d-%H%M%S)"  # Changed to /root/pipe
            echo -e "${GREEN}Backup saved to: $HOME/node_info.backup-$(date +%Y%m%d-%H%M%S)${NC}"
        fi
        
        echo -e "${BLUE}Removing node files...${NC}"
        sudo rm -rf /root/pipe  # Changed to /root/pipe
        sudo rm -rf "$CACHE_DIR"
        
        echo -e "${BLUE}Removing service user...${NC}"
        sudo userdel -r pop-svc-user 2>/dev/null
        
        echo -e "${GREEN}Node uninstalled successfully!${NC}"
        echo -e "${YELLOW}Note: Configuration backup has been saved in your home directory${NC}"
    else
        echo -e "${BLUE}Uninstallation cancelled.${NC}"
    fi
}

# Configure node
configure_node() {
    echo -e "${BLUE}Current Configuration:${NC}"
    echo -e "Solana Address: ${YELLOW}${SOLANA_KEY}${NC}"
    echo -e "RAM Size: ${YELLOW}${RAM_SIZE}GB${NC}"
    echo -e "Disk Size: ${YELLOW}${DISK_SIZE}GB${NC}"
    echo -e "Cache Directory: ${YELLOW}${CACHE_DIR}${NC}"
    echo
    
    local new_solana=""
    while true; do
        read -p "Enter new Solana wallet address (or press Enter to keep current): " new_solana
        if [ -z "$new_solana" ]; then
            break
        fi
        
        valid_address=$(validate_solana_address "$new_solana")
        if [ ! -z "$valid_address" ]; then
            SOLANA_KEY="$valid_address"
            break
        else
            echo -e "${RED}Error: Invalid Solana address. Please check your address and try again.${NC}"
            echo -e "${YELLOW}Make sure your address:${NC}"
            echo -e "  - Is 32-44 characters long"
            echo -e "  - Contains only valid characters (no spaces or special characters)"
            echo -e "  - Is copied correctly from your wallet"
        fi
    done

    read -p "Enter new RAM size in GB (or press Enter to keep current): " new_ram
    read -p "Enter new disk size in GB (or press Enter to keep current): " new_disk
    read -p "Enter new cache directory path (or press Enter to keep current): " new_cache

    if [ ! -z "$new_ram" ]; then
        RAM_SIZE=$new_ram
    fi
    if [ ! -z "$new_disk" ]; then
        DISK_SIZE=$new_disk
    fi
    if [ ! -z "$new_cache" ]; then
        sudo mkdir -p "$new_cache"
        CACHE_DIR=$new_cache
        sudo chown -R pop-svc-user:pop-svc-user "$CACHE_DIR"
    fi

    save_config

    if check_installation; then
        echo -e "${YELLOW}Updating service configuration...${NC}"
        create_service
        echo -e "${GREEN}Configuration updated!${NC}"
    else
        echo -e "${GREEN}Configuration saved!${NC}"
    fi
}

# Install node function
install_node() {
    echo -e "${BLUE}=== Pipe DevNet 2 Node Installation ===${NC}"
    
    # Check if node is already installed
    if [ -f "/root/pipe/node_info.json" ]; then  # Changed to /root/pipe
        echo -e "${RED}A node is already installed on this system!${NC}"
        echo -e "${YELLOW}Note: Referral codes can only be used during the first installation.${NC}"
        read -p "Do you want to completely reinstall the node? This will remove existing configuration! (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Installation cancelled.${NC}"
            return 1
        fi
        # Backup and remove existing configuration
        echo -e "${YELLOW}Backing up existing configuration...${NC}"
        backup_node
        sudo systemctl stop pipe.service 2>/dev/null  # Changed service name to pipe.service
        sudo rm -f /root/pipe/node_info.json  # Changed to /root/pipe
    fi

    # Referral Code Input (Only for fresh installation)
    echo -e "\n${BLUE}Referral Code Configuration${NC}"
    echo -e "${YELLOW}Note: Referral codes can only be used during initial installation${NC}"
    read -p "Do you have a referral code? (y/N): " has_referral
    local referral_cmd=""

    if [[ $has_referral =~ ^[Yy]$ ]]; then
        read -p "Enter your referral code: " referral_code
        if [ ! -z "$referral_code" ]; then
            referral_cmd="--signup-by-referral-route $referral_code"
            echo -e "${GREEN}Referral code will be used during installation${NC}\n"
        fi
    fi

    # Solana Wallet Configuration
    echo -e "\nSolana Wallet Configuration"
    echo -e "Your Solana wallet address is needed to receive rewards"
    local valid_address=""
    while [ -z "$valid_address" ]; do
        read -p "Enter your Solana wallet address: " setup_solana
        valid_address=$(validate_solana_address "$setup_solana")
        
        if [ -z "$valid_address" ]; then
            echo -e "${RED}Error: Invalid Solana address. Please check your address and try again.${NC}"
            echo -e "${YELLOW}Make sure your address:${NC}"
            echo -e "  - Is 32-44 characters long"
            echo -e "  - Contains only valid characters (no spaces or special characters)"
            echo -e "  - Is copied correctly from your wallet"
        fi
    done
    SOLANA_KEY="$valid_address"

    # RAM Configuration
    echo -e "\nRAM Configuration"
    echo -e "Recommended: 8GB minimum"
    read -p "Enter RAM size in GB [default: ${DEFAULT_RAM}]: " setup_ram
    RAM_SIZE=${setup_ram:-$DEFAULT_RAM}

    # Disk Configuration
    echo -e "\nDisk Configuration"
    echo -e "Recommended: 200-500GB"
    read -p "Enter disk size in GB [default: ${DEFAULT_DISK}]: " setup_disk
    DISK_SIZE=${setup_disk:-$DEFAULT_DISK}

    # Cache Directory Configuration
    echo -e "\nCache Directory Configuration"
    echo -e "Default: ${DEFAULT_CACHE_DIR}"
    read -p "Enter cache directory path [default: ${DEFAULT_CACHE_DIR}]: " setup_cache
    CACHE_DIR=${setup_cache:-$DEFAULT_CACHE_DIR}

    # Save configuration
    save_config
    
    # Create service user
    sudo useradd -r -m -s /sbin/nologin pop-svc-user -d /home/pop-svc-user 2>/dev/null || true

    # Create directories
    sudo mkdir -p /root/pipe
    sudo mkdir -p "$CACHE_DIR"
    sudo chown -R pop-svc-user:pop-svc-user "$CACHE_DIR"

    # Download binary
    curl -L -o /root/pipe/pop "${DOWNLOAD_URL}"  # Changed to /root/pipe
    chmod +x /root/pipe/pop  # Changed to /root/pipe
    
    # Install the node
    echo -e "${BLUE}Installing node...${NC}"
    if [ ! -z "$referral_cmd" ]; then
        echo -e "${YELLOW}Using referral code: ${referral_code}${NC}"
        /root/pipe/pop $referral_cmd  # Changed to /root/pipe
    else
        echo -e "${YELLOW}Installing without referral code${NC}"
        /root/pipe/pop  # Changed to /root/pipe
    fi
    
    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Node installation successful!${NC}"
        sudo mv -f /root/pipe/pop /root/pipe/  # Changed to /root/pipe
        sudo mv /root/pipe/node_info.json /root/pipe/  # Changed to /root/pipe
        # Create and start service
        create_service
        echo -e "${GREEN}Node service created and started!${NC}"
    else
        echo -e "${RED}Node installation failed. Please try again in an hour.${NC}"
        echo -e "${YELLOW}If you need immediate setup, you can try using a different IP address.${NC}"
        exit 1
    fi
}

# Start node
start_node() {
    if ! check_running; then
        echo -e "${BLUE}Starting node...${NC}"
        sudo systemctl start pipe.service  # Changed service name to pipe.service
        echo -e "${GREEN}Node started!${NC}"
    else
        echo -e "${YELLOW}Node is already running!${NC}"
    fi
}

# Stop node
stop_node() {
    if check_running; then
        echo -e "${BLUE}Stopping node...${NC}"
        sudo systemctl stop pipe.service  # Changed service name to pipe.service
        echo -e "${GREEN}Node stopped!${NC}"
    else
        echo -e "${YELLOW}Node is not running!${NC}"
    fi
}

# Load initial configuration
load_config

# Main menu
while true; do
    echo -e "\n${BLUE}=== Pipe DevNet 2 Node Manager by ${AUTHOR} ===${NC}"
    echo -e "${BLUE}Current configuration: ${YELLOW}${RAM_SIZE}GB RAM, ${DISK_SIZE}GB Disk${NC}"
    echo -e "${BLUE}Cache directory: ${YELLOW}${CACHE_DIR}${NC}"
    echo -e "${BLUE}Status: ${NC}$(check_installation && echo -e "${GREEN}Installed${NC}" || echo -e "${RED}Not Installed${NC}"), $(check_running && echo -e "${GREEN}Running${NC}" || echo -e "${RED}Stopped${NC}")"
    echo -e "${BLUE}Node ID: ${PINK}$(get_node_id)${NC}"
    echo
    
    if ! check_installation; then
        echo "1. Install node"
    else
        if check_running; then
            echo "1. Stop node"
        else
            echo "1. Start node"
        fi
    fi
    
    echo "2. Show status"
    echo "3. Generate referral code"
    echo "4. Backup node"
    echo "5. Update node"
    echo "6. Configure node"
    echo "7. Uninstall node"
    echo "8. Exit"
    
    read -p "Choose an option (1-8): " choice
    
    case $choice in
        1)
            if ! check_installation; then
                install_node
                clear
            else
                if check_running; then
                    stop_node
                    sleep 2
                    clear
                else
                    start_node
                    sleep 2
                    clear
                fi
            fi
            ;;

        2)
            if check_installation; then
                show_status
                read -p "Press Enter to continue..."
                clear
            else
                echo -e "${RED}Node is not installed!${NC}"
                sleep 2
                clear
            fi
            ;;

        3)
            if check_installation; then
                generate_referral
                read -p "Press Enter to continue..."
                clear
            else
                echo -e "${RED}Node is not installed!${NC}"
                sleep 2
                clear
            fi
            ;;

        4)
            if check_installation; then
                backup_node
                sleep 2
                clear
            else
                echo -e "${RED}Node is not installed!${NC}"
                sleep 2
                clear
            fi
            ;;

        5)
            if check_installation; then
                update_node
                sleep 2
                clear
            else
                echo -e "${RED}Node is not installed!${NC}"
                sleep 2
                clear
            fi
            ;;

        6)
            configure_node
            sleep 2
            clear
            ;;

        7)
            if check_installation; then
                uninstall_node
                sleep 2
                clear
            else
                echo -e "${RED}No node installation found!${NC}"
                sleep 2
                clear
            fi
            ;;

        8)
            clear
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 2
            clear
            ;;
    esac
done

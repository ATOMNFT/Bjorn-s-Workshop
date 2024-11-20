#!/bin/bash

# BJORN Comments Installation Script
# This script handles the complete installation of BJORN's custom comments
# Author: Atomnft
# Version: 1.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging configuration
LOG_DIR="/var/log/bjorn_install"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bjorn_install_$(date +%Y%m%d_%H%M%S).log"
VERBOSE=false

# Global variables
BJORN_USER="bjorn"
BJORN_PATH="/home/${BJORN_USER}/Bjorn"
TARGET_DIR="/home/${BJORN_USER}/Bjorn/resources/comments"
GITHUB_RAW_URL="https://raw.githubusercontent.com/ATOMNFT/Bjorns-Workshop/main/Comments/Viking-Styled-comments.json"
TEMP_FILE="/tmp/comments.json"
CURRENT_STEP=0
TOTAL_STEPS=5

# Function to display progress
show_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${BLUE}Step $CURRENT_STEP of $TOTAL_STEPS: $1${NC}"
    log "INFO" "$1"
}

# Logging function
log() {
    local level=$1
    shift
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo -e "$message" >> "$LOG_FILE"
    if [ "$VERBOSE" = true ] || [ "$level" != "DEBUG" ]; then
        case $level in
            "ERROR") echo -e "${RED}$message${NC}" ;;
            "SUCCESS") echo -e "${GREEN}$message${NC}" ;;
            "WARNING") echo -e "${YELLOW}$message${NC}" ;;
            "INFO") echo -e "${BLUE}$message${NC}" ;;
            *) echo -e "$message" ;;
        esac
    fi
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    log "ERROR" "This script must be run as root. Exiting."
    exit 1
fi

# Step 1: Ensure target directory exists
show_progress "Ensuring target directory exists..."
if [ ! -d "$TARGET_DIR" ]; then
    log "INFO" "Target directory does not exist. Creating it..."
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to create target directory. Exiting."
        exit 1
    fi
fi

# Step 2: Download comments.json file
show_progress "Downloading comments.json file from GitHub repository..."
wget -q -O "$TEMP_FILE" "$GITHUB_RAW_URL"
if [ $? -ne 0 ]; then
    log "ERROR" "Failed to download the comments.json file. Exiting."
    exit 1
fi

# Step 3: Rename and move the file
show_progress "Renaming the file to 'comments.json' and moving it to target directory..."
mv "$TEMP_FILE" "$TARGET_DIR/comments.json"
if [ $? -ne 0 ]; then
    log "ERROR" "Failed to move the comments.json file to the target directory. Exiting."
    exit 1
fi
log "SUCCESS" "comments.json has been installed to $TARGET_DIR."

# Step 4: Inform about reboot
show_progress "Notifying user of impending reboot..."
log "WARNING" "System will reboot in 10 seconds. Save your work!"
sleep 10

# Step 5: Reboot the system
show_progress "Rebooting the system..."
sudo reboot

#!/usr/bin/env bash

set -e

# COLORS
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}🚀 Starting SaveTime CLI installation...${RESET}"

# Function to check and install a required package
check_or_install() {
  local cmd_check=$1
  local pkg_name=$2
  local url=$3

  if ! command -v "$cmd_check" &> /dev/null; then
    echo -e "${YELLOW}🔍 $pkg_name not found. Attempting to install...${RESET}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update
      sudo apt install -y "$pkg_name" || echo -e "${RED}❌ Failed to install $pkg_name. Please install it manually: $url${RESET}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew is required to install $pkg_name. Please install Homebrew first: https://brew.sh${RESET}"
        return
      fi
      brew install "$pkg_name" || echo -e "${RED}❌ Failed to install $pkg_name. Please install it manually: $url${RESET}"
    else
      echo -e "${RED}❌ Unsupported OS. Please install $pkg manually: $url${RESET}"
    fi
  else
    echo -e "${GREEN}✔ $pkg_name is already installed.${RESET}"
  fi
}

# Step 1: Check dependencies
check_or_install git git "https://git-scm.com/downloads"
check_or_install docker docker "https://docs.docker.com/get-docker/"

# Check for docker compose (subcommand)
if docker compose version &>/dev/null; then
  echo -e "${GREEN}✔ Docker Compose is available as a Docker subcommand.${RESET}"
else
  echo -e "${RED}❌ Docker Compose (subcommand) is not available.${RESET}"
  echo -e "${YELLOW}👉 Please install or update Docker: https://docs.docker.com/get-docker/${RESET}"
fi

# Step 2: Create 'savetime' user if it doesn't exist
if id "savetime" &>/dev/null; then
  echo -e "${GREEN}✔ User 'savetime' already exists.${RESET}"
else
  echo -e "${YELLOW}➕ Creating user 'savetime'...${RESET}"
  sudo useradd -m -s /bin/bash savetime
  echo -e "${YELLOW}🔑 Please set a password for the 'savetime' user:${RESET}"
  sudo passwd savetime
fi

# Step 3: Set permissions
echo -e "${GREEN}⚙️ Setting file permissions...${RESET}"

# Change owner to actually user
CURRENT_USER=$(whoami)
sudo chown -R $CURRENT_USER:$CURRENT_USER ./core

# Step 4: Copy .env
if [[ -f "./core/.env.example" ]]; then
  cp ./core/.env.example ./core/.env
  echo -e "${GREEN}✔ .env file created from .env.example.${RESET}"
else
  echo -e "${RED}❌ ./core/.env.example not found. Skipping .env setup.${RESET}"
fi

# Step 5: Create global 'st' command
echo -e "${YELLOW}🔗 Creating global command 'st'...${RESET}"

sudo rm -f /usr/local/bin/st
sudo ln -sf "$(pwd)/core/st" /usr/local/bin/st

if [[ -f "/usr/local/bin/st" ]]; then
  sudo chmod +x /usr/local/bin/st
else
  echo -e "${RED}❌ Failed to create /usr/local/bin/st symlink.${RESET}"
fi

echo -e "${GREEN}✔ 'st' command is now available globally.${RESET}"

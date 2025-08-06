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
  local pkg=$1
  local url=$2
  if ! command -v "$pkg" &> /dev/null; then
    echo -e "${YELLOW}🔍 $pkg not found. Attempting to install...${RESET}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update
      sudo apt install -y "$pkg" || echo -e "${RED}❌ Failed to install $pkg. Please install it manually: $url${RESET}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew is required to install $pkg. Please install Homebrew first: https://brew.sh${RESET}"
        return
      fi
      brew install "$pkg" || echo -e "${RED}❌ Failed to install $pkg. Please install it manually: $url${RESET}"
    else
      echo -e "${RED}❌ Unsupported OS. Please install $pkg manually: $url${RESET}"
    fi
  else
    echo -e "${GREEN}✔ $pkg is already installed.${RESET}"
  fi
}

# Step 1: Check dependencies
check_or_install git "https://git-scm.com/downloads"
check_or_install docker "https://docs.docker.com/get-docker/"
check_or_install docker-compose "https://docs.docker.com/compose/install/"

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
sudo chown -R savetime:savetime ./core
sudo chmod +x ./core/commands/sv

# Step 4: Copy .env
if [[ -f "./core/.env.example" ]]; then
  cp ./core/.env.example ./core/.env
  echo -e "${GREEN}✔ .env file created from .env.example.${RESET}"
else
  echo -e "${RED}❌ ./core/.env.example not found. Skipping .env setup.${RESET}"
fi

# Step 5: Create global 'sv' command
echo -e "${YELLOW}🔗 Creating global command 'sv'...${RESET}"
sudo ln -sf "$(pwd)/core/commands/sv" /usr/local/bin/sv
sudo chmod +x /usr/local/bin/sv
echo -e "${GREEN}✔ 'sv' command is now available globally.${RESET}"

echo -e "${GREEN}✅ Installation complete! You can now use the 'sv' command to start your workspace.${RESET}"

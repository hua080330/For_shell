#!/bin/bash

# Qiusuo Mathmatica Download Script for macOS
# Repo: https://github.com/hua080330/qssx

REPO_OWNER="hua080330"
REPO_NAME="qssx"
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/"

# GitHub 加速代理列表
PROXY_LIST=(
    "https://ghproxy.net/https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main/"
    "https://ghproxy.com/https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main/"
    "https://hub.fastgit.xyz/https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main/"
    "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main/"
)

# Colorful ASCII Art Logo
echo -e "\033[31m"
echo "    ######   ####### "
echo "   ##    ##  ##      "
echo "   ##    ##  #####   "
echo "   ## ## ##  ##      "
echo "   ###  ###  ##      "
echo "   ##    ##  ##      "
echo "   ##    ##  ##      "
echo -e "\033[0m"

echo -e "\033[36m"
echo "   ##########  ##########  ##########"
echo "   ##       ## ##       ## ##       ##"
echo "   ##       ## ##       ## ##       ##"
echo "   ##       ## ##       ## ##########"
echo "   ##       ## ##       ## ##########"
echo "   ##       ## ##       ## ##       ##"
echo "   ##########  ##########  ##       ##"
echo -e "\033[0m"

echo -e "\033[35m"
echo "  ######  ####### "
echo "  ##   ## ##      "
echo "  ##   ## #####   "
echo "  ##   ## ##      "
echo "  ######  ####### "
echo "  ##      ##      "
echo "  ##      ####### "
echo -e "\033[0m"

echo -e "\033[33m            === Quantum Scale Download Station ===\033[0m"
echo ""

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "\033[31m[-] curl not found. Please install Command Line Tools: xcode-select --install\033[0m"
    read -p "Press Enter to exit"
    exit 1
fi

echo -e "\033[32m[+] Fetching file list from GitHub...\033[0m"

# Get file list from GitHub API
RESPONSE=$(curl -s "$API_URL")

# Parse file names
FILE_NAMES=$(echo "$RESPONSE" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g')

if [ -z "$FILE_NAMES" ]; then
    echo -e "\033[31m[-] Cannot fetch file list. Please check network.\033[0m"
    read -p "Press Enter to exit"
    exit 1
fi

# Display file list
echo -e "\n\033[36m[*] Available Files:\033[0m"
echo -e "\033[90m==================================================\033[0m"

INDEX=1
declare -a NAMES
while IFS= read -r NAME; do
    if [ -n "$NAME" ]; then
        NAMES+=("$NAME")
        echo -e "\033[33m [$INDEX]\033[0m \033[37m$NAME\033[0m"
        ((INDEX++))
    fi
done <<< "$FILE_NAMES"

echo -e "\033[90m==================================================\033[0m"

if [ ${#NAMES[@]} -eq 0 ]; then
    echo -e "\033[31m[-] No files found.\033[0m"
    read -p "Press Enter to exit"
    exit 1
fi

# User selection
echo ""
read -p "[?] Enter number (1-${#NAMES[@]}) or 0 to exit: " SELECTION

if [ "$SELECTION" = "0" ]; then
    echo -e "\033[90m[!] Cancelled.\033[0m"
    exit 0
fi

SELECTED_INDEX=$((SELECTION - 1))
if [ $SELECTED_INDEX -lt 0 ] || [ $SELECTED_INDEX -ge ${#NAMES[@]} ]; then
    echo -e "\033[31m[-] Invalid selection.\033[0m"
    read -p "Press Enter to exit"
    exit 1
fi

SELECTED_NAME="${NAMES[$SELECTED_INDEX]}"

# Try each proxy to download
echo -e "\n\033[36m[+] Downloading: $SELECTED_NAME ...\033[0m"

DOWNLOAD_SUCCESS=0
for PROXY in "${PROXY_LIST[@]}"; do
    DOWNLOAD_URL="${PROXY}${SELECTED_NAME}"
    echo -e "\033[90m[.] Trying: ${PROXY}\033[0m"
    
    curl -L -o "$SELECTED_NAME" --connect-timeout 5 "$DOWNLOAD_URL"
    
    if [ $? -eq 0 ] && [ -f "$SELECTED_NAME" ] && [ -s "$SELECTED_NAME" ]; then
        echo -e "\033[32m[+] Download completed! Saved to: $(pwd)/$SELECTED_NAME\033[0m"
        DOWNLOAD_SUCCESS=1
        break
    else
        echo -e "\033[31m[-] Failed, trying next proxy...\033[0m"
        rm -f "$SELECTED_NAME"
    fi
done

if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
    echo -e "\033[31m[-] All download sources failed. Please try again later.\033[0m"
fi

echo ""
read -p "Press Enter to exit"

#!/bin/bash

# Qiusuo Mathmatica Download Script for macOS
# Repo: https://gitee.com/qssxmathmatica/qssx

REPO_OWNER="qssxmathmatica"
REPO_NAME="qssx"
TOKEN="90bf089b807622662ccd8b2dbcb2aa07"
API_URL="https://gitee.com/api/v5/repos/$REPO_OWNER/$REPO_NAME/contents/?access_token=$TOKEN"

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

echo -e "\033[32m[+] Fetching file list from Gitee...\033[0m"

# Get file list
RESPONSE=$(curl -s "$API_URL")

# Parse files
FILE_LIST=$(echo "$RESPONSE" | grep -o '"name":"[^"]*","type":"file"[^}]*"size":[0-9]*' | sed 's/"name":"//g' | sed 's/","type":"file",.*"size"://g')

if [ -z "$FILE_LIST" ]; then
    echo -e "\033[31m[-] Cannot fetch file list. Please check network.\033[0m"
    read -p "Press Enter to exit"
    exit 1
fi

# Display file list
declare -a NAMES
declare -a SIZES
INDEX=1

echo -e "\n\033[36m[*] Available Files:\033[0m"
echo -e "\033[90m==================================================\033[0m"
while IFS=':' read -r NAME SIZE; do
    if [ -n "$NAME" ]; then
        NAMES+=("$NAME")
        SIZES+=("$SIZE")
        KB_SIZE=$(echo "scale=2; $SIZE/1024" | bc)
        echo -e "\033[33m [$INDEX]\033[0m \033[37m$NAME\033[0m \033[90m($KB_SIZE KB)\033[0m"
        ((INDEX++))
    fi
done <<< "$FILE_LIST"
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
DOWNLOAD_URL="https://gitee.com/$REPO_OWNER/$REPO_NAME/raw/main/$(echo "$SELECTED_NAME" | sed 's/ /%20/g')"

# Download file
echo -e "\n\033[36m[+] Downloading: $SELECTED_NAME ...\033[0m"
curl -L -o "$SELECTED_NAME" "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    echo -e "\033[32m[+] Download completed! Saved to: $(pwd)/$SELECTED_NAME\033[0m"
else
    echo -e "\033[31m[-] Download failed.\033[0m"
fi

echo ""
read -p "Press Enter to exit"

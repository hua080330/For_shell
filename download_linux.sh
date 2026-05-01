#!/bin/bash

# Qiusuo Mathmatica Download Script for Linux
# 用途：通过 GitHub API 获取仓库文件列表，让用户交互式选择并下载

REPO_OWNER="hua080330"
REPO_NAME="qssx"

API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/"

# 检测是否安装 curl 或 wget
if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -L -o"
    USE_CURL=1
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -O"
    USE_CURL=0
else
    echo -e "\033[31m错误：未检测到 curl 或 wget，请先安装其中之一。\033[0m"
    echo "Ubuntu/Debian: sudo apt install curl"
    echo "CentOS/RHEL: sudo yum install curl"
    read -p "按 Enter 退出"
    exit 1
fi

echo -e "\033[36m正在获取可用文件列表...\033[0m"

# 获取文件列表
if [ $USE_CURL -eq 1 ]; then
    RESPONSE=$(curl -s "$API_URL")
else
    RESPONSE=$(wget -q -O - "$API_URL")
fi

# 解析 JSON（使用 grep + sed，不依赖 jq）
FILE_LIST=$(echo "$RESPONSE" | grep -o '"name":"[^"]*","type":"file"[^}]*"download_url":"[^"]*"' | sed 's/"name":"//g' | sed 's/","type":"file",.*"download_url":"/|/g' | sed 's/"//g')

if [ -z "$FILE_LIST" ]; then
    echo -e "\033[31m错误：无法获取文件列表或仓库为空。\033[0m"
    read -p "按 Enter 退出"
    exit 1
fi

# 显示文件列表
declare -a NAMES
declare -a URLS
INDEX=1

echo ""
while IFS='|' read -r NAME URL; do
    if [ -n "$NAME" ] && [ -n "$URL" ]; then
        NAMES+=("$NAME")
        URLS+=("$URL")
        echo -e "\033[33m[$INDEX] $NAME\033[0m"
        ((INDEX++))
    fi
done <<< "$FILE_LIST"

if [ ${#NAMES[@]} -eq 0 ]; then
    echo -e "\033[31m未找到任何可下载文件。\033[0m"
    read -p "按 Enter 退出"
    exit 1
fi

# 用户选择
echo ""
read -p "请输入编号 (1-${#NAMES[@]}) 或输入 0 退出: " SELECTION

if [ "$SELECTION" = "0" ]; then
    echo -e "\033[90m已取消下载。\033[0m"
    exit 0
fi

SELECTED_INDEX=$((SELECTION - 1))
if [ $SELECTED_INDEX -lt 0 ] || [ $SELECTED_INDEX -ge ${#NAMES[@]} ]; then
    echo -e "\033[31m无效的选择。\033[0m"
    read -p "按 Enter 退出"
    exit 1
fi

SELECTED_NAME="${NAMES[$SELECTED_INDEX]}"
SELECTED_URL="${URLS[$SELECTED_INDEX]}"

# 下载文件
echo -e "\n\033[36m正在下载: $SELECTED_NAME ...\033[0m"

if [ $USE_CURL -eq 1 ]; then
    curl -L -o "$SELECTED_NAME" "$SELECTED_URL"
else
    wget -O "$SELECTED_NAME" "$SELECTED_URL"
fi

if [ $? -eq 0 ]; then
    echo -e "\033[32m下载完成！文件已保存至: $(pwd)/$SELECTED_NAME\033[0m"
else
    echo -e "\033[31m下载失败。\033[0m"
fi

echo ""
read -p "按 Enter 退出"

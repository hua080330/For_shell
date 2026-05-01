#!/bin/bash

# Qiusuo Mathmatica Download Script for macOS
# 用途：通过 GitHub API 获取仓库文件列表，让用户交互式选择并下载

REPO_OWNER="hua080330"
REPO_NAME="qssx"

API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/"

echo -e "\033[36m正在获取可用文件列表...\033[0m"

# 获取文件列表
FILES=$(curl -s "$API_URL" | grep -E '"name"|"type"|"download_url"' | paste -d ' ' - - - | grep -v '"type": "dir"' || echo "")

if [ -z "$FILES" ]; then
    echo -e "\033[31m错误：无法获取文件列表或仓库为空。\033[0m"
    echo "按 Enter 退出"
    read
    exit 1
fi

# 解析文件名和下载链接
declare -a NAMES
declare -a URLS
INDEX=1

while IFS= read -r line; do
    NAME=$(echo "$line" | grep -o '"name": "[^"]*"' | cut -d '"' -f 4)
    DL_URL=$(echo "$line" | grep -o '"download_url": "[^"]*"' | cut -d '"' -f 4)
    if [ -n "$NAME" ] && [ -n "$DL_URL" ]; then
        NAMES+=("$NAME")
        URLS+=("$DL_URL")
        echo -e "\033[33m[$INDEX] $NAME\033[0m"
        ((INDEX++))
    fi
done <<< "$FILES"

if [ ${#NAMES[@]} -eq 0 ]; then
    echo -e "\033[31m未找到任何可下载文件。\033[0m"
    echo "按 Enter 退出"
    read
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
curl -L -o "$SELECTED_NAME" "$SELECTED_URL"

if [ $? -eq 0 ]; then
    echo -e "\033[32m下载完成！文件已保存至: $(pwd)/$SELECTED_NAME\033[0m"
else
    echo -e "\033[31m下载失败。\033[0m"
fi

echo ""
read -p "按 Enter 退出"

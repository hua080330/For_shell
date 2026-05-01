# Qiusuo Mathmatica Download Script
# 用途：通过 GitHub API 获取仓库文件列表，让用户交互式选择并下载

$repoOwner = "hua080330"
$repoName = "qssx"

# 获取仓库根目录文件列表
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/"
Write-Host "正在获取可用文件列表..." -ForegroundColor Cyan

try {
    $files = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
}
catch {
    Write-Host "错误：无法连接到 GitHub API。请检查网络后重试。" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit
}

# 筛选出文件（排除目录）
$fileList = $files | Where-Object { $_.type -eq "file" }

if ($fileList.Count -eq 0) {
    Write-Host "未找到任何可下载文件。" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit
}

# 显示文件列表
Write-Host "`n========== 可下载文件列表 ==========" -ForegroundColor Green
for ($i = 0; $i -lt $fileList.Count; $i++) {
    Write-Host "[$($i+1)] $($fileList[$i].name)" -ForegroundColor Yellow
}

# 用户选择
$selection = Read-Host "`n请输入编号 (1-$($fileList.Count)) 或输入 0 退出"

if ($selection -eq 0) {
    Write-Host "已取消下载。" -ForegroundColor Gray
    exit
}

$selectedIndex = [int]$selection - 1
if ($selectedIndex -lt 0 -or $selectedIndex -ge $fileList.Count) {
    Write-Host "无效的选择。" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit
}

$selectedFile = $fileList[$selectedIndex]
$downloadUrl = $selectedFile.download_url
$fileName = $selectedFile.name

# 下载文件
Write-Host "`n正在下载: $fileName ..." -ForegroundColor Cyan
$downloadPath = Join-Path -Path $PWD -ChildPath $fileName

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    Write-Host "下载完成！文件已保存至: $downloadPath" -ForegroundColor Green
}
catch {
    Write-Host "下载失败: $_" -ForegroundColor Red
}

Read-Host "`n按 Enter 退出"

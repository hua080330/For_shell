# Qiusuo Mathmatica Download Script for Windows
# Repo: https://github.com/hua080330/qssx

$repoOwner = "hua080330"
$repoName = "qssx"
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/"

# GitHub 加速代理列表
$proxyList = @(
    "https://ghproxy.net/https://raw.githubusercontent.com/$repoOwner/$repoName/main/",
    "https://ghproxy.com/https://raw.githubusercontent.com/$repoOwner/$repoName/main/",
    "https://hub.fastgit.xyz/https://raw.githubusercontent.com/$repoOwner/$repoName/main/",
    "https://raw.githubusercontent.com/$repoOwner/$repoName/main/"
)

# Colorful ASCII Art Logo
Write-Host @"
    ######   ####### 
   ##    ##  ##      
   ##    ##  #####   
   ## ## ##  ##      
   ###  ###  ##      
   ##    ##  ##      
   ##    ##  ##      
"@ -ForegroundColor Red

Write-Host @"
   ##########  ##########  ##########
   ##       ## ##       ## ##       ##
   ##       ## ##       ## ##       ##
   ##       ## ##       ## ##########
   ##       ## ##       ## ##########
   ##       ## ##       ## ##       ##
   ##########  ##########  ##       ##
"@ -ForegroundColor Cyan

Write-Host @"
  ######  ####### 
  ##   ## ##      
  ##   ## #####   
  ##   ## ##      
  ######  ####### 
  ##      ##      
  ##      ####### 
"@ -ForegroundColor Magenta

Write-Host "            === Quantum Scale Download Station ===" -ForegroundColor Yellow
Write-Host ""

# Get file list
Write-Host "[+] Fetching file list from GitHub..." -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
}
catch {
    Write-Host "[-] Cannot connect to GitHub API. Please check your network." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

$fileList = $response | Where-Object { $_.type -eq "file" }

if ($fileList.Count -eq 0) {
    Write-Host "[-] No files found in repository." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Display file list
Write-Host "`n[*] Available Files:" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor DarkGray
for ($i = 0; $i -lt $fileList.Count; $i++) {
    Write-Host " [$($i+1)]" -ForegroundColor Yellow -NoNewline
    Write-Host " $($fileList[$i].name)" -ForegroundColor White
}
Write-Host ("=" * 50) -ForegroundColor DarkGray

# User selection
Write-Host ""
$selection = Read-Host "[?] Enter number (1-$($fileList.Count)) or 0 to exit"

if ($selection -eq 0) {
    Write-Host "[!] Cancelled." -ForegroundColor Gray
    exit
}

$selectedIndex = [int]$selection - 1
if ($selectedIndex -lt 0 -or $selectedIndex -ge $fileList.Count) {
    Write-Host "[-] Invalid selection." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

$selectedFile = $fileList[$selectedIndex]
$fileName = $selectedFile.name

# Try each proxy to download
Write-Host "`n[+] Downloading: $fileName ..." -ForegroundColor Cyan

$downloadSuccess = $false
foreach ($proxy in $proxyList) {
    $downloadUrl = $proxy + $fileName
    Write-Host "[.] Trying: $proxy" -ForegroundColor Gray
    
    try {
        $downloadPath = Join-Path -Path $PWD -ChildPath $fileName
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -TimeoutSec 10
        
        if ((Get-Item $downloadPath).Length -gt 0) {
            Write-Host "[+] Download completed! Saved to: $downloadPath" -ForegroundColor Green
            $downloadSuccess = $true
            break
        }
    }
    catch {
        Write-Host "[-] Failed, trying next proxy..." -ForegroundColor Red
        if (Test-Path $downloadPath) { Remove-Item $downloadPath }
    }
}

if (-not $downloadSuccess) {
    Write-Host "[-] All download sources failed. Please try again later." -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"

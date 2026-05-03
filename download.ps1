# Qiusuo Mathmatica Download Script
# Repo: https://gitee.com/qssxmathmatica/qssx

$repoOwner = "qssxmathmatica"
$repoName = "qssx"
$apiUrl = "https://gitee.com/api/v5/repos/$repoOwner/$repoName/contents/?access_token=90bf089b807622662ccd8b2dbcb2aa07"

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
Write-Host "[+] Fetching file list from Gitee..." -ForegroundColor Green

try {
    $files = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
}
catch {
    Write-Host "[-] Cannot connect to Gitee API. Please check your network." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

$fileList = $files | Where-Object { $_.type -eq "file" }

if ($fileList.Count -eq 0) {
    Write-Host "[-] No files found in repository." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Display file list
Write-Host "`n[*] Available Files:" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor DarkGray
for ($i = 0; $i -lt $fileList.Count; $i++) {
    $size = [math]::Round($fileList[$i].size / 1KB, 2)
    Write-Host " [$($i+1)]" -ForegroundColor Yellow -NoNewline
    Write-Host " $($fileList[$i].name) " -ForegroundColor White -NoNewline
    Write-Host "($size KB)" -ForegroundColor Gray
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
$downloadUrl = $selectedFile.download_url
$fileName = $selectedFile.name

# Download file
Write-Host "`n[+] Downloading: $fileName ..." -ForegroundColor Cyan
$downloadPath = Join-Path -Path $PWD -ChildPath $fileName

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    Write-Host "[+] Download completed! Saved to: $downloadPath" -ForegroundColor Green
}
catch {
    Write-Host "[-] Download failed: $_" -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"

# ============================================================
# Qiusuo Mathmatica Downloader - One-Click Setup
# ============================================================
# This script downloads the full interactive downloader to your desktop
# Run this command in PowerShell:
#   iex (irm https://raw.githubusercontent.com/hua080330/For_shell/main/setup.ps1)
# ============================================================

#region Banner
Clear-Host
Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ██████╗ ██╗   ██╗██╗███████╗██╗   ██╗ ██████╗            ║
║    ██╔═══██╗██║   ██║██║██╔════╝██║   ██║██╔═══██╗           ║
║    ██║   ██║██║   ██║██║███████╗██║   ██║██║   ██║           ║
║    ██║▄▄ ██║██║   ██║██║╚════██║██║   ██║██║   ██║           ║
║    ╚██████╔╝╚██████╔╝██║███████║╚██████╔╝╚██████╔╝           ║
║     ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝            ║
║                                                              ║
║                 Qiusuo Downloader Setup                     ║
║                 One-Click Installation                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`n[INFO] This installer will set up Qiusuo Downloader on your system.`n" -ForegroundColor Yellow
#endregion

#region Configuration
$script:repoOwner = "hua080330"
$script:repoName = "For_shell"
$script:mainScriptUrl = "https://raw.githubusercontent.com/$script:repoOwner/$script:repoName/main/download.ps1"
$script:desktopPath = [Environment]::GetFolderPath("Desktop")
$script:configDir = "$env:USERPROFILE\.qiusuo"
$script:mainScriptPath = Join-Path $script:desktopPath "qiusuo.ps1"
$script:shortcutPath = Join-Path $script:desktopPath "Qiusuo Downloader.lnk"
$script:cmdLauncherPath = Join-Path $script:desktopPath "qiusuo.cmd"
#endregion

#region Functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-ErrorMsg {
    param([string]$Message, [string]$Solution = "")
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    if ($Solution) { Write-Host "[TIP] $Solution" -ForegroundColor Yellow }
}

function Write-SuccessMsg {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-InfoMsg {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-WarningMsg {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}
#endregion

#region Step 1: Create Config Directory
Write-InfoMsg "Step 1/6: Creating configuration directory..."
try {
    if (-not (Test-Path $script:configDir)) {
        New-Item -ItemType Directory -Path $script:configDir -Force | Out-Null
        Write-SuccessMsg "Created: $script:configDir"
    }
    else {
        Write-InfoMsg "Directory already exists: $script:configDir"
    }
    
    $subDirs = @("logs", "profiles", "downloads")
    foreach ($subDir in $subDirs) {
        $subPath = Join-Path $script:configDir $subDir
        if (-not (Test-Path $subPath)) {
            New-Item -ItemType Directory -Path $subPath -Force | Out-Null
            Write-SuccessMsg "Created: $subPath"
        }
    }
}
catch {
    Write-ErrorMsg "Failed to create config directory: $_" "Check disk space and permissions"
    pause
    exit 1
}
#endregion

#region Step 2: Create Default Configuration
Write-InfoMsg "Step 2/6: Creating default configuration..."
$configPath = Join-Path $script:configDir "config.json"
if (-not (Test-Path $configPath)) {
    $defaultConfig = @{
        DOWNLOAD_DIR   = Join-Path $script:configDir "downloads"
        PROXY_INDEX    = 1
        AUTO_CONFIRM   = $true
        THREADS        = 4
        SPEED_LIMIT    = 0
        RESUME         = $true
        LOG_LEVEL      = "INFO"
        SHOW_PROGRESS   = $true
        ACTIVE_PROFILE = "default"
    } | ConvertTo-Json
    Set-Content -Path $configPath -Value $defaultConfig
    Write-SuccessMsg "Created: $configPath"
}
else {
    Write-InfoMsg "Config file already exists: $configPath"
}
#endregion

#region Step 3: Download Main Script
Write-InfoMsg "Step 3/6: Downloading main program from GitHub..."
try {
    Invoke-WebRequest -Uri $script:mainScriptUrl -OutFile $script:mainScriptPath -UseBasicParsing -ErrorAction Stop
    Write-SuccessMsg "Downloaded to: $script:mainScriptPath"
    Write-InfoMsg "File size: $([math]::Round((Get-Item $script:mainScriptPath).Length/1KB, 2)) KB"
}
catch {
    Write-ErrorMsg "Failed to download main script: $_" "Check your internet connection and try again"
    pause
    exit 1
}
#endregion

#region Step 4: Create Desktop Shortcut
Write-InfoMsg "Step 4/6: Creating desktop shortcut..."
try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($script:shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$script:mainScriptPath`""
    $shortcut.WorkingDirectory = $script:configDir
    $shortcut.IconLocation = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe,0"
    $shortcut.Description = "Qiusuo Mathmatica Downloader - Interactive CLI Tool"
    $shortcut.Save()
    Write-SuccessMsg "Created shortcut: $script:shortcutPath"
}
catch {
    Write-ErrorMsg "Failed to create shortcut: $_" "You can create it manually"
}
#endregion

#region Step 5: Create CMD Launcher
Write-InfoMsg "Step 5/6: Creating CMD launcher..."
$launcherContent = @"
@echo off
title Qiusuo Downloader
color 0A
echo.
echo    ╔══════════════════════════════════════════════════════════════╗
echo    ║                                                              ║
echo    ║     ██████╗ ██╗   ██╗██╗███████╗██╗   ██╗ ██████╗            ║
echo    ║    ██╔═══██╗██║   ██║██║██╔════╝██║   ██║██╔═══██╗           ║
echo    ║    ██║   ██║██║   ██║██║███████╗██║   ██║██║   ██║           ║
echo    ║    ██║▄▄ ██║██║   ██║██║╚════██║██║   ██║██║   ██║           ║
echo    ║    ╚██████╔╝╚██████╔╝██║███████║╚██████╔╝╚██████╔╝           ║
echo    ║     ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝            ║
echo    ║                                                              ║
echo    ║                 Qiusuo Downloader v2.0                      ║
echo    ║                                                              ║
echo    ╚══════════════════════════════════════════════════════════════╝
echo.
echo    [INFO] Starting Qiusuo Downloader...
echo    [TIP] Type 'help' or '?' for available commands
echo    [TIP] First time, run 'list' to load files
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0qiusuo.ps1"
pause
"@
Set-Content -Path $script:cmdLauncherPath -Value $launcherContent
Write-SuccessMsg "Created CMD launcher: $script:cmdLauncherPath"
#endregion

#region Step 6: Add to PATH (Optional)
Write-InfoMsg "Step 6/6: Do you want to add Qiusuo to system PATH?"
Write-Host "  This allows you to run 'qiusuo' from any Command Prompt" -ForegroundColor Gray
$addToPath = Read-Host "[?] Add to PATH? (y/n) [default: y]"
if ($addToPath -eq '' -or $addToPath -eq 'y' -or $addToPath -eq 'Y') {
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$script:desktopPath*") {
            $newPath = "$currentPath;$script:desktopPath"
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-SuccessMsg "Added to PATH. You can now run 'qiusuo' from anywhere."
            Write-WarningMsg "Note: Restart your terminal for PATH changes to take effect."
        }
        else {
            Write-InfoMsg "Already in PATH"
        }
    }
    catch {
        Write-ErrorMsg "Failed to add to PATH" "You can manually add $script:desktopPath to your system PATH"
    }
}
else {
    Write-InfoMsg "Skipping PATH addition"
}
#endregion

#region Step 7: Create Uninstall Script
$uninstallPath = Join-Path $script:desktopPath "uninstall_qiusuo.ps1"
$uninstallContent = @"
# Qiusuo Downloader - Uninstall Script
# Run this script to remove all Qiusuo files

Write-Host "[INFO] Uninstalling Qiusuo Downloader..." -ForegroundColor Cyan

`$configDir = "$env:USERPROFILE\.qiusuo"
`$desktopPath = [Environment]::GetFolderPath("Desktop")

# Remove shortcuts
`$shortcuts = @("Qiusuo Downloader.lnk", "qiusuo.cmd", "qiusuo.ps1", "uninstall_qiusuo.ps1")
foreach (`$sc in `$shortcuts) {
    `$path = Join-Path `$desktopPath `$sc
    if (Test-Path `$path) { Remove-Item `$path -Force }
}

# Remove config directory (optional)
`$confirm = Read-Host "[?] Remove all configuration files? (y/n)"
if (`$confirm -eq 'y' -or `$confirm -eq 'Y') {
    if (Test-Path `$configDir) { Remove-Item `$configDir -Recurse -Force }
    Write-Host "[SUCCESS] Removed configuration files" -ForegroundColor Green
}
else {
    Write-Host "[INFO] Keeping configuration files in `$configDir" -ForegroundColor Yellow
}

# Remove from PATH
`$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
`$newPath = (`$currentPath -split ';' | Where-Object { `$_ -ne `$desktopPath }) -join ';'
[Environment]::SetEnvironmentVariable("Path", `$newPath, "User")

Write-Host "[SUCCESS] Uninstall completed!" -ForegroundColor Green
pause
"@
Set-Content -Path $uninstallPath -Value $uninstallContent
Write-SuccessMsg "Created uninstall script: $uninstallPath"
#endregion

#region Completion Summary
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    INSTALLATION COMPLETE                     ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n[INFO] Installation Summary:" -ForegroundColor Cyan
Write-Host "  - Main Program: $script:mainScriptPath" -ForegroundColor White
Write-Host "  - Desktop Shortcut: $script:shortcutPath" -ForegroundColor White
Write-Host "  - CMD Launcher: $script:cmdLauncherPath" -ForegroundColor White
Write-Host "  - Config Directory: $script:configDir" -ForegroundColor White
Write-Host "  - Uninstall Script: $uninstallPath" -ForegroundColor White

Write-Host "`n[INFO] How to use:" -ForegroundColor Cyan
Write-Host "  1. Double-click 'Qiusuo Downloader' on your desktop" -ForegroundColor White
Write-Host "  2. Or type 'qiusuo' in any Command Prompt (if added to PATH)" -ForegroundColor White
Write-Host "  3. Or run: powershell -File `"$script:mainScriptPath`"" -ForegroundColor White

Write-Host "`n[INFO] Quick Start:" -ForegroundColor Cyan
Write-Host "  - First time, type 'list' to load files from repository" -ForegroundColor White
Write-Host "  - Type 'dl 1' to download the first file" -ForegroundColor White
Write-Host "  - Type 'help' for all commands" -ForegroundColor White

Write-Host "`n[INFO] To uninstall: Double-click 'uninstall_qiusuo.ps1' on desktop`n" -ForegroundColor Yellow

$runNow = Read-Host "[?] Do you want to run Qiusuo Downloader now? (y/n)"
if ($runNow -eq 'y' -or $runNow -eq 'Y') {
    Write-InfoMsg "Starting Qiusuo Downloader..."
    powershell -ExecutionPolicy Bypass -File $script:mainScriptPath
}
else {
    Write-InfoMsg "Setup completed! You can start the program anytime from your desktop."
}

pause
#endregion

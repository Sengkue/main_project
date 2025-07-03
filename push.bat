# Automated Git Push Scripts

Collection of scripts to automate your Git workflow with intelligent commit messages and push operations.

## 🚀 Windows Batch File (`git-push.bat`)

```batch
@echo off
setlocal enabledelayedexpansion

echo ================================
echo    AUTOMATED GIT PUSH TOOL
echo ================================
echo.

:: Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Not a Git repository!
    echo Please run this script from a Git repository folder.
    pause
    exit /b 1
)

:: Show current status
echo 📊 Current Git Status:
echo --------------------------------
git status --short
echo.

:: Check if there are any changes
git diff --quiet
set changes_staged=%errorlevel%

git diff --cached --quiet
set changes_unstaged=%errorlevel%

if %changes_staged% equ 0 if %changes_unstaged% equ 0 (
    echo ✅ No changes to commit.
    pause
    exit /b 0
)

:: Auto-add all changes
echo 📝 Adding all changes...
git add .

:: Get commit message from user or auto-generate
set /p commit_msg="💬 Enter commit message (or press Enter for auto-generated): "

if "!commit_msg!"=="" (
    :: Auto-generate commit message based on changes
    echo 🤖 Generating automatic commit message...
    
    :: Count file changes
    for /f %%i in ('git diff --cached --name-only ^| find /c /v ""') do set file_count=%%i
    
    :: Get current date and time
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
    set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%"
    
    :: Check for common patterns
    git diff --cached --name-only | findstr /i "\.md$" >nul
    if %errorlevel% equ 0 (
        set commit_msg=📝 Update documentation - !file_count! files - %DD%/%MM%/%YY%
    ) else (
        git diff --cached --name-only | findstr /i "\.(js|ts|jsx|tsx)$" >nul
        if %errorlevel% equ 0 (
            set commit_msg=💻 Code updates - !file_count! files - %DD%/%MM%/%YY%
        ) else (
            git diff --cached --name-only | findstr /i "\.(css|scss|sass)$" >nul
            if %errorlevel% equ 0 (
                set commit_msg=🎨 Style updates - !file_count! files - %DD%/%MM%/%YY%
            ) else (
                set commit_msg=🔄 Update project files - !file_count! files - %DD%/%MM%/%YY%
            )
        )
    )
    
    echo Generated message: !commit_msg!
)

:: Commit changes
echo 💾 Committing changes...
git commit -m "!commit_msg!"

if %errorlevel% neq 0 (
    echo ❌ Commit failed!
    pause
    exit /b 1
)

:: Get current branch
for /f %%i in ('git branch --show-current') do set current_branch=%%i

:: Push to remote
echo 🚀 Pushing to origin/%current_branch%...
git push origin %current_branch%

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS! Changes pushed to remote repository.
    echo 📍 Branch: %current_branch%
    echo 💬 Message: !commit_msg!
) else (
    echo.
    echo ❌ Push failed! You may need to pull changes first.
    echo 🔄 Try running: git pull origin %current_branch%
)

echo.
echo 📋 Recent commits:
git log --oneline -5

echo.
pause
```

## 🐧 Linux/Mac Shell Script (`git-push.sh`)

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
ROCKET="🚀"
CHECK="✅"
CROSS="❌"
ROBOT="🤖"
FILE="📝"
COMPUTER="💻"
ART="🎨"
REFRESH="🔄"
LOCATION="📍"
SPEECH="💬"
CHART="📊"
SAVE="💾"
CLIPBOARD="📋"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    AUTOMATED GIT PUSH TOOL${NC}"
echo -e "${BLUE}================================${NC}"
echo

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${CROSS} ${RED}Error: Not a Git repository!${NC}"
    echo "Please run this script from a Git repository folder."
    exit 1
fi

# Show current status
echo -e "${CHART} ${YELLOW}Current Git Status:${NC}"
echo "--------------------------------"
git status --short
echo

# Check if there are any changes
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${CHECK} ${GREEN}No changes to commit.${NC}"
    exit 0
fi

# Auto-add all changes
echo -e "${FILE} ${YELLOW}Adding all changes...${NC}"
git add .

# Get commit message from user or auto-generate
echo -e "${SPEECH} Enter commit message (or press Enter for auto-generated):"
read -r commit_msg

if [ -z "$commit_msg" ]; then
    # Auto-generate commit message based on changes
    echo -e "${ROBOT} ${CYAN}Generating automatic commit message...${NC}"
    
    # Count file changes
    file_count=$(git diff --cached --name-only | wc -l)
    
    # Get current date and time
    current_date=$(date +"%d/%m/%y")
    current_time=$(date +"%H:%M")
    
    # Check for common patterns and generate appropriate message
    if git diff --cached --name-only | grep -q '\.(md|txt|rst)$'; then
        commit_msg="${FILE} Update documentation - $file_count files - $current_date"
    elif git diff --cached --name-only | grep -q '\.(js|ts|jsx|tsx|py|java|cpp|c|go|rs)$'; then
        commit_msg="${COMPUTER} Code updates - $file_count files - $current_date"
    elif git diff --cached --name-only | grep -q '\.(css|scss|sass|less)$'; then
        commit_msg="${ART} Style updates - $file_count files - $current_date"
    elif git diff --cached --name-only | grep -q '\.(json|yml|yaml|xml|config)$'; then
        commit_msg="⚙️ Configuration updates - $file_count files - $current_date"
    elif git diff --cached --name-only | grep -q '\.(png|jpg|jpeg|gif|svg|ico)$'; then
        commit_msg="🖼️ Asset updates - $file_count files - $current_date"
    else
        commit_msg="${REFRESH} Update project files - $file_count files - $current_date"
    fi
    
    echo -e "Generated message: ${GREEN}$commit_msg${NC}"
fi

# Commit changes
echo -e "${SAVE} ${YELLOW}Committing changes...${NC}"
if ! git commit -m "$commit_msg"; then
    echo -e "${CROSS} ${RED}Commit failed!${NC}"
    exit 1
fi

# Get current branch
current_branch=$(git branch --show-current)

# Push to remote
echo -e "${ROCKET} ${YELLOW}Pushing to origin/$current_branch...${NC}"
if git push origin "$current_branch"; then
    echo
    echo -e "${CHECK} ${GREEN}SUCCESS! Changes pushed to remote repository.${NC}"
    echo -e "${LOCATION} ${BLUE}Branch:${NC} $current_branch"
    echo -e "${SPEECH} ${BLUE}Message:${NC} $commit_msg"
else
    echo
    echo -e "${CROSS} ${RED}Push failed! You may need to pull changes first.${NC}"
    echo -e "${REFRESH} ${YELLOW}Try running:${NC} git pull origin $current_branch"
    exit 1
fi

echo
echo -e "${CLIPBOARD} ${PURPLE}Recent commits:${NC}"
git log --oneline -5 --color=always

echo
echo -e "${GREEN}🎉 All done! Happy coding! 🎉${NC}"
```

## 🔧 PowerShell Script (`git-push.ps1`)

```powershell
# PowerShell Git Auto-Push Script
param(
    [string]$Message = "",
    [switch]$Force,
    [switch]$Verbose
)

# Colors and emojis
$colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    Magenta = "Magenta"
}

function Write-ColoredOutput {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Header {
    Write-ColoredOutput "================================" "Blue"
    Write-ColoredOutput "    AUTOMATED GIT PUSH TOOL" "Blue"
    Write-ColoredOutput "================================" "Blue"
    Write-Host ""
}

function Test-GitRepository {
    try {
        git rev-parse --git-dir | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-GitStatus {
    $status = git status --porcelain
    if ($status) {
        Write-ColoredOutput "📊 Current Git Status:" "Yellow"
        Write-ColoredOutput "--------------------------------" "Gray"
        git status --short
        Write-Host ""
        return $true
    }
    else {
        Write-ColoredOutput "✅ No changes to commit." "Green"
        return $false
    }
}

function Generate-CommitMessage {
    $fileCount = (git diff --cached --name-only | Measure-Object).Count
    $currentDate = Get-Date -Format "dd/MM/yy"
    
    # Get changed file types
    $changedFiles = git diff --cached --name-only
    
    if ($changedFiles -match '\.(md|txt|rst)$') {
        return "📝 Update documentation - $fileCount files - $currentDate"
    }
    elseif ($changedFiles -match '\.(js|ts|jsx|tsx|py|java|cpp|c|go|rs)$') {
        return "💻 Code updates - $fileCount files - $currentDate"
    }
    elseif ($changedFiles -match '\.(css|scss|sass|less)$') {
        return "🎨 Style updates - $fileCount files - $currentDate"
    }
    elseif ($changedFiles -match '\.(json|yml|yaml|xml|config)$') {
        return "⚙️ Configuration updates - $fileCount files - $currentDate"
    }
    elseif ($changedFiles -match '\.(png|jpg|jpeg|gif|svg|ico)$') {
        return "🖼️ Asset updates - $fileCount files - $currentDate"
    }
    else {
        return "🔄 Update project files - $fileCount files - $currentDate"
    }
}

function Main {
    Write-Header
    
    # Check if we're in a Git repository
    if (-not (Test-GitRepository)) {
        Write-ColoredOutput "❌ Error: Not a Git repository!" "Red"
        Write-ColoredOutput "Please run this script from a Git repository folder." "Yellow"
        return
    }
    
    # Show current status
    if (-not (Get-GitStatus)) {
        return
    }
    
    # Add all changes
    Write-ColoredOutput "📝 Adding all changes..." "Yellow"
    git add .
    
    # Get commit message
    if (-not $Message) {
        $userMessage = Read-Host "💬 Enter commit message (or press Enter for auto-generated)"
        if ($userMessage) {
            $Message = $userMessage
        }
        else {
            Write-ColoredOutput "🤖 Generating automatic commit message..." "Cyan"
            $Message = Generate-CommitMessage
            Write-ColoredOutput "Generated message: $Message" "Green"
        }
    }
    
    # Commit changes
    Write-ColoredOutput "💾 Committing changes..." "Yellow"
    try {
        git commit -m $Message
        Write-ColoredOutput "✅ Commit successful!" "Green"
    }
    catch {
        Write-ColoredOutput "❌ Commit failed!" "Red"
        return
    }
    
    # Get current branch
    $currentBranch = git branch --show-current
    
    # Push to remote
    Write-ColoredOutput "🚀 Pushing to origin/$currentBranch..." "Yellow"
    try {
        if ($Force) {
            git push origin $currentBranch --force
        }
        else {
            git push origin $currentBranch
        }
        
        Write-Host ""
        Write-ColoredOutput "✅ SUCCESS! Changes pushed to remote repository." "Green"
        Write-ColoredOutput "📍 Branch: $currentBranch" "Blue"
        Write-ColoredOutput "💬 Message: $Message" "Blue"
    }
    catch {
        Write-Host ""
        Write-ColoredOutput "❌ Push failed! You may need to pull changes first." "Red"
        Write-ColoredOutput "🔄 Try running: git pull origin $currentBranch" "Yellow"
        return
    }
    
    # Show recent commits
    Write-Host ""
    Write-ColoredOutput "📋 Recent commits:" "Magenta"
    git log --oneline -5
    
    Write-Host ""
    Write-ColoredOutput "🎉 All done! Happy coding! 🎉" "Green"
}

# Run the main function
Main
```

## 📱 Quick Setup Instructions

### Windows Setup:
1. **Save** the batch file as `git-push.bat`
2. **Place** it in your project folder or add to PATH
3. **Run** by double-clicking or typing `git-push` in terminal

### Linux/Mac Setup:
1. **Save** the script as `git-push.sh`
2. **Make executable**: `chmod +x git-push.sh`
3. **Optional**: Move to `/usr/local/bin/` for global access
4. **Run**: `./git-push.sh` or `git-push.sh`

### PowerShell Setup:
1. **Save** as `git-push.ps1`
2. **Enable scripts**: `Set-ExecutionPolicy RemoteSigned`
3. **Run**: `.\git-push.ps1` or `.\git-push.ps1 -Message "Custom message"`

## 🎯 Features

### ✨ Smart Features:
- **Auto-detection** of Git repositories
- **Intelligent commit messages** based on file types
- **Colorful output** with emojis
- **Error handling** with helpful suggestions
- **Recent commits display**
- **Cross-platform compatibility**

### 🤖 Auto-Generated Messages:
- **Documentation**: `📝 Update documentation - X files`
- **Code**: `💻 Code updates - X files`
- **Styles**: `🎨 Style updates - X files`
- **Config**: `⚙️ Configuration updates - X files`
- **Assets**: `🖼️ Asset updates - X files`
- **General**: `🔄 Update project files - X files`

### 🔧 PowerShell Parameters:
- `-Message "Your message"`: Custom commit message
- `-Force`: Force push (use carefully!)
- `-Verbose`: Detailed output

## 🚀 Usage Examples

```bash
# Basic usage
./git-push.sh

# With custom message
./git-push.ps1 -Message "🐛 Fix critical bug in authentication"

# Force push (careful!)
./git-push.ps1 -Force
```

These scripts will save you tons of time and make your Git workflow super smooth! 🎉
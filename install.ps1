# Claude Code Agent Suite - Windows Installation Script
# Author: @qepting91
# Repository: https://github.com/qepting91/claude-agent-suite

param(
    [switch]$LocalBuild,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host "Options:"
    Write-Host "  -LocalBuild    Build agents locally using Python (requires Python 3.10+)"
    Write-Host "  -Help          Show this help message"
    exit 0
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Claude Code Agent Suite Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get Claude directory
$CLAUDE_DIR = "$HOME\.claude"
$BACKUP_DIR = "$HOME\.claude.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$SCRIPT_DIR = $PSScriptRoot
$BACKUP_CREATED = $false
$GITHUB_RELEASE_URL = "https://github.com/qepting91/claude-agent-suite/releases/latest/download/claude-agents.zip"

# Validation Functions

# Function: Validate agent has proper YAML frontmatter
function Validate-AgentFrontmatter {
    param([string]$AgentFile)

    $agentName = Split-Path -Leaf $AgentFile

    # Check file size (> 100 bytes)
    $fileSize = (Get-Item $AgentFile).Length
    if ($fileSize -lt 100) {
        Write-Host "  ✗ Invalid: $agentName (too small: ${fileSize}B)" -ForegroundColor Red
        return $false
    }

    # Read file content
    $content = Get-Content $AgentFile -Raw

    # Check for YAML frontmatter
    if ($content -notmatch '(?ms)^---\r?\n.*?\r?\n---') {
        Write-Host "  ✗ Invalid: $agentName (no YAML frontmatter)" -ForegroundColor Red
        return $false
    }

    # Extract frontmatter (between first two ---)
    $frontmatter = ($content -split '---')[1]

    # Check required fields
    $requiredFields = @('name:', 'description:', 'tools:', 'model:')
    foreach ($field in $requiredFields) {
        if ($frontmatter -notmatch "(?m)^$field") {
            Write-Host "  ✗ Invalid: $agentName (missing $field)" -ForegroundColor Red
            return $false
        }
    }

    return $true
}

# Function: Detect if repository was cloned with git
function Test-GitRepository {
    if (-not (Test-Path (Join-Path $SCRIPT_DIR ".git"))) {
        Write-Host "  ⚠ Not a git repository (downloaded as ZIP?)" -ForegroundColor Yellow
        Write-Host "    Future updates via 'git pull' will not work" -ForegroundColor Yellow
        Write-Host "    Recommended: git clone https://github.com/qepting91/claude-agent-suite.git" -ForegroundColor Cyan
        $response = Read-Host "  Continue anyway? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            exit 0
        }
    }
}

# Function: Rollback on failure
function Invoke-Rollback {
    Write-Host "`nInstallation failed! Rolling back..." -ForegroundColor Red
    if ($BACKUP_CREATED) {
        Remove-Item -Recurse -Force $CLAUDE_DIR -ErrorAction SilentlyContinue
        Move-Item $BACKUP_DIR $CLAUDE_DIR
        Write-Host "Rollback complete. Original configuration restored." -ForegroundColor Green
    } else {
        Write-Host "No backup to restore (was fresh install)." -ForegroundColor Yellow
    }
    exit 1
}

# Check if Claude Code is installed
Write-Host "[1/7] Checking prerequisites..." -ForegroundColor Yellow
try {
    $claudeVersion = claude --version 2>&1
    Write-Host "  ✓ Claude Code is installed: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Claude Code is not installed!" -ForegroundColor Red
    Write-Host "  Please install Claude Code first:" -ForegroundColor Red
    Write-Host "  irm https://claude.ai/install.ps1 | iex" -ForegroundColor Yellow
    exit 1
}

# Check repository type
Test-GitRepository

# Create backup
Write-Host "`n[2/7] Creating backup..." -ForegroundColor Yellow
if (Test-Path $CLAUDE_DIR) {
    Write-Host "  Creating backup: $BACKUP_DIR" -ForegroundColor Cyan
    try {
        Copy-Item -Recurse $CLAUDE_DIR $BACKUP_DIR

        # Verify backup
        if (Test-Path $BACKUP_DIR) {
            $backupAgentCount = @(Get-ChildItem -Path "$BACKUP_DIR\agents" -Filter "*.md" -ErrorAction SilentlyContinue).Count
            $originalAgentCount = @(Get-ChildItem -Path "$CLAUDE_DIR\agents" -Filter "*.md" -ErrorAction SilentlyContinue).Count

            if (($backupAgentCount -eq $originalAgentCount) -or ($originalAgentCount -eq 0)) {
                $BACKUP_CREATED = $true
                Write-Host "  ✓ Backup created and verified" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Backup verification failed!" -ForegroundColor Red
                exit 1
            }
        }
    } catch {
        Write-Host "  ✗ Failed to create backup: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ℹ No .claude directory found (fresh install, no backup needed)" -ForegroundColor Cyan
}

# Create directories
Write-Host "`n[3/7] Creating directories..." -ForegroundColor Yellow
$directories = @(
    "$CLAUDE_DIR\agents"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "  ✓ Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  ℹ Exists: $dir" -ForegroundColor Cyan
    }
}

# Get agents (download from GitHub Release or build locally)
if ($LocalBuild) {
    Write-Host "`n[4/7] Building agents locally..." -ForegroundColor Yellow
    Write-Host "  Running build system (scripts/build.py)..." -ForegroundColor Cyan

    # Check if Python is available
    $pythonCmd = $null
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        $pythonCmd = "python3"
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $pythonCmd = "python"
    } else {
        Write-Host "  ✗ Python is not installed!" -ForegroundColor Red
        Write-Host "  Python 3.10+ is required for local builds." -ForegroundColor Red
        Invoke-Rollback
    }

    # Run the build system
    try {
        Push-Location $SCRIPT_DIR
        & $pythonCmd scripts/build.py
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }
        Write-Host "  ✓ Build completed successfully" -ForegroundColor Green
        Pop-Location
    } catch {
        Write-Host "  ✗ Build failed!" -ForegroundColor Red
        Pop-Location
        Invoke-Rollback
    }
} else {
    Write-Host "`n[4/7] Downloading pre-built agents..." -ForegroundColor Yellow
    Write-Host "  Fetching latest release from GitHub..." -ForegroundColor Cyan

    $tempZip = Join-Path $env:TEMP "claude-agents-$(Get-Random).zip"
    $downloadSuccess = $false

    try {
        Invoke-WebRequest -Uri $GITHUB_RELEASE_URL -OutFile $tempZip -UseBasicParsing -ErrorAction Stop
        $downloadSuccess = $true
    } catch {
        Write-Host "  ⚠ Download failed: $_" -ForegroundColor Yellow
        Write-Host "  Falling back to local build..." -ForegroundColor Cyan
    }

    if ($downloadSuccess) {
        try {
            # Extract to script directory
            $extractPath = Join-Path $SCRIPT_DIR ".claude"
            if (-not (Test-Path $extractPath)) {
                New-Item -ItemType Directory -Force -Path $extractPath | Out-Null
            }
            Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
            Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ Downloaded and extracted agents" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠ Failed to extract: $_" -ForegroundColor Yellow
            Write-Host "  Falling back to local build..." -ForegroundColor Cyan
            Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
            $downloadSuccess = $false
        }
    }

    # Fallback to local build
    if (-not $downloadSuccess) {
        $pythonCmd = $null
        if (Get-Command python3 -ErrorAction SilentlyContinue) {
            $pythonCmd = "python3"
        } elseif (Get-Command python -ErrorAction SilentlyContinue) {
            $pythonCmd = "python"
        } else {
            Write-Host "  ✗ Python is not installed and download failed!" -ForegroundColor Red
            Invoke-Rollback
        }

        try {
            Push-Location $SCRIPT_DIR
            & $pythonCmd scripts/build.py
            if ($LASTEXITCODE -ne 0) {
                throw "Build failed with exit code $LASTEXITCODE"
            }
            Write-Host "  ✓ Fallback build completed" -ForegroundColor Green
            Pop-Location
        } catch {
            Write-Host "  ✗ Build failed!" -ForegroundColor Red
            Pop-Location
            Invoke-Rollback
        }
    }
}

# Copy agents with validation
Write-Host "`n[5/7] Installing agents..." -ForegroundColor Yellow

$EXPECTED_AGENTS = 15
$COPIED_AGENTS = 0

$agentsSource = Join-Path $SCRIPT_DIR ".claude\agents"
if (Test-Path $agentsSource) {
    # Validate all agents first
    Write-Host "  Validating agent files..." -ForegroundColor Cyan
    $agentFiles = Get-ChildItem -Path $agentsSource -Filter "*.md"
    foreach ($file in $agentFiles) {
        if (-not (Validate-AgentFrontmatter -AgentFile $file.FullName)) {
            Write-Host "  Validation failed! Repository may be corrupted." -ForegroundColor Red
            Invoke-Rollback
        }
    }

    # Copy validated agents
    Write-Host "  Copying agents..." -ForegroundColor Cyan
    foreach ($file in $agentFiles) {
        $destPath = Join-Path "$CLAUDE_DIR\agents" $file.Name

        try {
            Copy-Item -Force $file.FullName "$CLAUDE_DIR\agents\"

            # Verify copy succeeded
            if (Test-Path $destPath) {
                $COPIED_AGENTS++
                Write-Host "  ✓ Installed: $($file.Name)" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Copy verification failed: $($file.Name)" -ForegroundColor Red
                Invoke-Rollback
            }
        } catch {
            Write-Host "  ✗ Failed to copy: $($file.Name)" -ForegroundColor Red
            Invoke-Rollback
        }
    }

    # Verify expected count
    if ($COPIED_AGENTS -ne $EXPECTED_AGENTS) {
        Write-Host "  ✗ Agent count mismatch! Expected $EXPECTED_AGENTS, got $COPIED_AGENTS" -ForegroundColor Red
        Invoke-Rollback
    }

    Write-Host "  ✓ All $COPIED_AGENTS agents installed successfully" -ForegroundColor Green
} else {
    Write-Host "  ✗ Built agents directory not found: $agentsSource" -ForegroundColor Red
    Write-Host "  This indicates the build system failed." -ForegroundColor Cyan
    Write-Host "    • Check build.py output above for errors" -ForegroundColor Gray
    Write-Host "    • Ensure Python 3.10+ is installed" -ForegroundColor Gray
    Write-Host "    • Verify requirements.txt dependencies" -ForegroundColor Gray
    Invoke-Rollback
}

# Copy documentation
Write-Host "`n[6/7] Installing documentation..." -ForegroundColor Yellow
$docsSource = Join-Path $SCRIPT_DIR "docs"
if (Test-Path $docsSource) {
    $docFiles = Get-ChildItem -Path $docsSource -Filter "*.md"
    foreach ($file in $docFiles) {
        Copy-Item -Force $file.FullName $CLAUDE_DIR
        Write-Host "  ✓ Installed: $($file.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ Docs directory not found, skipping..." -ForegroundColor Yellow
}

# Merge settings
Write-Host "`n[7/7] Configuring settings..." -ForegroundColor Yellow
$settingsSource = Join-Path $SCRIPT_DIR "config\settings.json"
$settingsTarget = Join-Path $CLAUDE_DIR "settings.json"

if (Test-Path $settingsSource) {
    if (Test-Path $settingsTarget) {
        Write-Host "  ℹ Existing settings.json found" -ForegroundColor Cyan
        Write-Host "  ⚠ Manual merge required for settings.json" -ForegroundColor Yellow
        Write-Host "    Source: $settingsSource" -ForegroundColor Gray
        Write-Host "    Target: $settingsTarget" -ForegroundColor Gray
        Write-Host "    Please review and merge the hooks and permissions manually." -ForegroundColor Gray
    } else {
        Copy-Item -Force $settingsSource $settingsTarget
        Write-Host "  ✓ Installed: settings.json" -ForegroundColor Green
    }
} else {
    Write-Host "  ℹ No settings.json template found, skipping..." -ForegroundColor Cyan
}

# Verify installation
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan

Write-Host "`n📊 Installation Summary:" -ForegroundColor Cyan
$agentCount = (Get-ChildItem -Path "$CLAUDE_DIR\agents" -Filter "*.md").Count
Write-Host "  • Agents installed: $agentCount" -ForegroundColor White
Write-Host "  • Configuration: $CLAUDE_DIR" -ForegroundColor White

# Only show backup if one was created
if ($BACKUP_CREATED) {
    Write-Host "  • Backup location: $BACKUP_DIR" -ForegroundColor White
    Write-Host "    (Restore: Remove-Item -Recurse ~/.claude; Move-Item $BACKUP_DIR ~/.claude)" -ForegroundColor Gray
}

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open Claude Code and run: /agents" -ForegroundColor White
Write-Host "  2. Install code intelligence plugins (optional):" -ForegroundColor White
Write-Host "     /plugin install pyright-lsp@claude-plugins-official" -ForegroundColor Gray
Write-Host "     /plugin install typescript-lsp@claude-plugins-official" -ForegroundColor Gray
Write-Host "     /plugin install gopls-lsp@claude-plugins-official" -ForegroundColor Gray
Write-Host "  3. Install Trail of Bits security skills:" -ForegroundColor White
Write-Host "     /plugin marketplace add trailofbits/skills" -ForegroundColor Gray
Write-Host "  4. Read the documentation:" -ForegroundColor White
Write-Host "     $CLAUDE_DIR\AGENT_TEAM_GUIDE.md" -ForegroundColor Gray

Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
Write-Host "  • Complete Guide: $CLAUDE_DIR\AGENT_TEAM_GUIDE.md" -ForegroundColor White
Write-Host "  • Security Skills: $CLAUDE_DIR\integrate-trailofbits.md" -ForegroundColor White

Write-Host "`n✨ Happy coding with your new AI agent team!" -ForegroundColor Green
Write-Host ""

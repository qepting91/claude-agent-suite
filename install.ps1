# Claude Code Agent Suite - Windows Installation Script
# Author: @qepting91
# Repository: https://github.com/qepting91/claude-agent-suite

$ErrorActionPreference = "Stop"

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Claude Code Agent Suite Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get Claude directory
$CLAUDE_DIR = "$HOME\.claude"
$BACKUP_DIR = "$HOME\.claude.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$SCRIPT_DIR = $PSScriptRoot

# Check if Claude Code is installed
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow
try {
    $claudeVersion = claude --version 2>&1
    Write-Host "  ✓ Claude Code is installed: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Claude Code is not installed!" -ForegroundColor Red
    Write-Host "  Please install Claude Code first:" -ForegroundColor Red
    Write-Host "  irm https://claude.ai/install.ps1 | iex" -ForegroundColor Yellow
    exit 1
}

# Create backup
Write-Host "`n[2/6] Creating backup..." -ForegroundColor Yellow
if (Test-Path $CLAUDE_DIR) {
    try {
        Copy-Item -Recurse $CLAUDE_DIR $BACKUP_DIR
        Write-Host "  ✓ Backup created: $BACKUP_DIR" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to create backup: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ℹ No existing .claude directory found (fresh install)" -ForegroundColor Cyan
}

# Create directories
Write-Host "`n[3/6] Creating directories..." -ForegroundColor Yellow
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

# Copy agents
Write-Host "`n[4/6] Installing agents..." -ForegroundColor Yellow
$agentsSource = Join-Path $SCRIPT_DIR "agents"
if (Test-Path $agentsSource) {
    $agentFiles = Get-ChildItem -Path $agentsSource -Filter "*.md"
    foreach ($file in $agentFiles) {
        Copy-Item -Force $file.FullName "$CLAUDE_DIR\agents\"
        Write-Host "  ✓ Installed: $($file.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ Agents directory not found!" -ForegroundColor Red
    exit 1
}

# Copy documentation
Write-Host "`n[5/6] Installing documentation..." -ForegroundColor Yellow
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
Write-Host "`n[6/6] Configuring settings..." -ForegroundColor Yellow
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
Write-Host "  • Backup location: $BACKUP_DIR" -ForegroundColor White

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

#!/bin/bash
# Claude Code Agent Suite - Linux/Mac Installation Script
# Author: @qepting91
# Repository: https://github.com/qepting91/claude-agent-suite

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "====================================="
echo "Claude Code Agent Suite Installer"
echo "====================================="
echo -e "${NC}"

# Get directories
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_CREATED=false

# Validation Functions

# Function: Validate agent has proper YAML frontmatter
validate_agent_frontmatter() {
  local agent_file="$1"
  local agent_name=$(basename "$agent_file")

  # Check file size (> 100 bytes)
  local file_size=$(stat -c%s "$agent_file" 2>/dev/null || stat -f%z "$agent_file" 2>/dev/null)
  if [ "$file_size" -lt 100 ]; then
    echo -e "${RED}  ✗ Invalid: $agent_name (too small: ${file_size}B)${NC}"
    return 1
  fi

  # Check for YAML frontmatter markers
  if ! grep -q "^---$" "$agent_file"; then
    echo -e "${RED}  ✗ Invalid: $agent_name (no YAML frontmatter)${NC}"
    return 1
  fi

  # Check required fields: name, description, tools, model
  local frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -n -1 | tail -n +2)
  for field in "name:" "description:" "tools:" "model:"; do
    if ! echo "$frontmatter" | grep -q "^$field"; then
      echo -e "${RED}  ✗ Invalid: $agent_name (missing $field)${NC}"
      return 1
    fi
  done

  return 0
}

# Function: Detect if repository was cloned with git
check_git_repository() {
  if [ ! -d "$SCRIPT_DIR/.git" ]; then
    echo -e "${YELLOW}  ⚠ Not a git repository (downloaded as ZIP?)${NC}"
    echo -e "${YELLOW}    Future updates via 'git pull' will not work${NC}"
    echo -e "${CYAN}    Recommended: git clone https://github.com/qepting91/claude-agent-suite.git${NC}"
    read -p "  Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 0
    fi
  fi
}

# Function: Rollback on failure
rollback_installation() {
  echo -e "\n${RED}Installation failed! Rolling back...${NC}"
  if [ "$BACKUP_CREATED" = true ]; then
    rm -rf "$CLAUDE_DIR"
    mv "$BACKUP_DIR" "$CLAUDE_DIR"
    echo -e "${GREEN}Rollback complete. Original configuration restored.${NC}"
  else
    echo -e "${YELLOW}No backup to restore (was fresh install).${NC}"
  fi
  exit 1
}

# Set trap for automatic rollback on error
trap rollback_installation ERR

# Check if Claude Code is installed
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 || echo "unknown")
    echo -e "${GREEN}  ✓ Claude Code is installed: $CLAUDE_VERSION${NC}"
else
    echo -e "${RED}  ✗ Claude Code is not installed!${NC}"
    echo -e "${RED}  Please install Claude Code first:${NC}"
    echo -e "${YELLOW}  curl -fsSL https://claude.ai/install.sh | bash${NC}"
    exit 1
fi

# Check repository type
check_git_repository

# Create backup
echo -e "\n${YELLOW}[2/7] Creating backup...${NC}"
if [ -d "$CLAUDE_DIR" ]; then
    echo -e "${CYAN}  Creating backup: $BACKUP_DIR${NC}"
    cp -r "$CLAUDE_DIR" "$BACKUP_DIR"

    # Verify backup
    if [ -d "$BACKUP_DIR" ]; then
        BACKUP_AGENT_COUNT=$(find "$BACKUP_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l || echo "0")
        ORIGINAL_AGENT_COUNT=$(find "$CLAUDE_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l || echo "0")

        if [ "$BACKUP_AGENT_COUNT" -eq "$ORIGINAL_AGENT_COUNT" ] || [ "$ORIGINAL_AGENT_COUNT" -eq 0 ]; then
            BACKUP_CREATED=true
            echo -e "${GREEN}  ✓ Backup created and verified${NC}"
        else
            echo -e "${RED}  ✗ Backup verification failed!${NC}"
            exit 1
        fi
    fi
else
    echo -e "${CYAN}  ℹ No .claude directory found (fresh install, no backup needed)${NC}"
fi

# Create directories
echo -e "\n${YELLOW}[3/7] Creating directories...${NC}"
mkdir -p "$CLAUDE_DIR/agents"
echo -e "${GREEN}  ✓ Created: $CLAUDE_DIR/agents${NC}"

# Build agents from source templates
echo -e "\n${YELLOW}[4/6] Building agents from source...${NC}"
echo -e "${CYAN}  Running build system (scripts/build.py)...${NC}"

# Check if Python is available
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}  ✗ Python is not installed!${NC}"
    echo -e "${RED}  Python 3.10+ is required to build agents.${NC}"
    rollback_installation
fi

# Run the build system
PYTHON_CMD=$(command -v python3 || command -v python)
if cd "$SCRIPT_DIR" && $PYTHON_CMD scripts/build.py; then
    echo -e "${GREEN}  ✓ Build completed successfully${NC}"
else
    echo -e "${RED}  ✗ Build failed!${NC}"
    rollback_installation
fi

# Copy agents with validation
echo -e "\n${YELLOW}[5/6] Installing agents...${NC}"

EXPECTED_AGENTS=15
COPIED_AGENTS=0

if [ -d "$SCRIPT_DIR/.claude/agents" ]; then
    # Validate all agents first
    echo -e "${CYAN}  Validating agent files...${NC}"
    for agent in "$SCRIPT_DIR/.claude/agents"/*.md; do
        [ -f "$agent" ] || continue
        if ! validate_agent_frontmatter "$agent"; then
            echo -e "${RED}  Validation failed! Repository may be corrupted.${NC}"
            rollback_installation
        fi
    done

    # Copy validated agents
    echo -e "${CYAN}  Copying agents...${NC}"
    for agent in "$SCRIPT_DIR/.claude/agents"/*.md; do
        [ -f "$agent" ] || continue
        agent_name=$(basename "$agent")

        if cp "$agent" "$CLAUDE_DIR/agents/"; then
            # Verify copy succeeded
            if [ -f "$CLAUDE_DIR/agents/$agent_name" ]; then
                ((COPIED_AGENTS++))
                echo -e "${GREEN}  ✓ Installed: $agent_name${NC}"
            else
                echo -e "${RED}  ✗ Copy verification failed: $agent_name${NC}"
                rollback_installation
            fi
        else
            echo -e "${RED}  ✗ Failed to copy: $agent_name${NC}"
            rollback_installation
        fi
    done

    # Verify expected count
    if [ $COPIED_AGENTS -ne $EXPECTED_AGENTS ]; then
        echo -e "${RED}  ✗ Agent count mismatch! Expected $EXPECTED_AGENTS, got $COPIED_AGENTS${NC}"
        rollback_installation
    fi

    echo -e "${GREEN}  ✓ All $COPIED_AGENTS agents installed successfully${NC}"
else
    echo -e "${RED}  ✗ Built agents directory not found: $SCRIPT_DIR/.claude/agents${NC}"
    echo -e "${CYAN}  This indicates the build system failed.${NC}"
    echo -e "${GRAY}    • Check build.py output above for errors${NC}"
    echo -e "${GRAY}    • Ensure Python 3.10+ is installed${NC}"
    echo -e "${GRAY}    • Verify requirements.txt dependencies${NC}"
    rollback_installation
fi

# Copy documentation
echo -e "\n${YELLOW}[6/7] Installing documentation...${NC}"
if [ -d "$SCRIPT_DIR/docs" ]; then
    for doc in "$SCRIPT_DIR/docs"/*.md; do
        if [ -f "$doc" ]; then
            cp "$doc" "$CLAUDE_DIR/"
            echo -e "${GREEN}  ✓ Installed: $(basename "$doc")${NC}"
        fi
    done
else
    echo -e "${YELLOW}  ⚠ Docs directory not found, skipping...${NC}"
fi

# Merge settings
echo -e "\n${YELLOW}[7/7] Configuring settings...${NC}"
if [ -f "$SCRIPT_DIR/config/settings.json" ]; then
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        echo -e "${CYAN}  ℹ Existing settings.json found${NC}"
        echo -e "${YELLOW}  ⚠ Manual merge required for settings.json${NC}"
        echo -e "${GRAY}    Source: $SCRIPT_DIR/config/settings.json${NC}"
        echo -e "${GRAY}    Target: $CLAUDE_DIR/settings.json${NC}"
        echo -e "${GRAY}    Please review and merge the hooks and permissions manually.${NC}"
    else
        cp "$SCRIPT_DIR/config/settings.json" "$CLAUDE_DIR/settings.json"
        echo -e "${GREEN}  ✓ Installed: settings.json${NC}"
    fi
else
    echo -e "${CYAN}  ℹ No settings.json template found, skipping...${NC}"
fi

# Verify installation
echo -e "\n${CYAN}====================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${CYAN}=====================================${NC}"

echo -e "\n${CYAN}📊 Installation Summary:${NC}"
AGENT_COUNT=$(find "$CLAUDE_DIR/agents" -name "*.md" -type f | wc -l)
echo -e "  • Agents installed: $AGENT_COUNT"
echo -e "  • Configuration: $CLAUDE_DIR"

# Only show backup if one was created
if [ "$BACKUP_CREATED" = true ]; then
    echo -e "  • Backup location: $BACKUP_DIR"
    echo -e "${GRAY}    (Restore: rm -rf ~/.claude && mv $BACKUP_DIR ~/.claude)${NC}"
fi

echo -e "\n${CYAN}🚀 Next Steps:${NC}"
echo -e "  1. Open Claude Code and run: ${YELLOW}/agents${NC}"
echo -e "  2. Install code intelligence plugins (optional):"
echo -e "${GRAY}     /plugin install pyright-lsp@claude-plugins-official${NC}"
echo -e "${GRAY}     /plugin install typescript-lsp@claude-plugins-official${NC}"
echo -e "${GRAY}     /plugin install gopls-lsp@claude-plugins-official${NC}"
echo -e "  3. Install Trail of Bits security skills:"
echo -e "${GRAY}     /plugin marketplace add trailofbits/skills${NC}"
echo -e "  4. Read the documentation:"
echo -e "${GRAY}     $CLAUDE_DIR/AGENT_TEAM_GUIDE.md${NC}"

echo -e "\n${CYAN}📚 Documentation:${NC}"
echo -e "  • Complete Guide: $CLAUDE_DIR/AGENT_TEAM_GUIDE.md"
echo -e "  • Security Skills: $CLAUDE_DIR/integrate-trailofbits.md"

echo -e "\n${GREEN}✨ Happy coding with your new AI agent team!${NC}\n"

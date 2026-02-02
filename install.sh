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

# Check if Claude Code is installed
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 || echo "unknown")
    echo -e "${GREEN}  ✓ Claude Code is installed: $CLAUDE_VERSION${NC}"
else
    echo -e "${RED}  ✗ Claude Code is not installed!${NC}"
    echo -e "${RED}  Please install Claude Code first:${NC}"
    echo -e "${YELLOW}  curl -fsSL https://claude.ai/install.sh | bash${NC}"
    exit 1
fi

# Create backup
echo -e "\n${YELLOW}[2/6] Creating backup...${NC}"
if [ -d "$CLAUDE_DIR" ]; then
    cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}  ✓ Backup created: $BACKUP_DIR${NC}"
else
    echo -e "${CYAN}  ℹ No existing .claude directory found (fresh install)${NC}"
fi

# Create directories
echo -e "\n${YELLOW}[3/6] Creating directories...${NC}"
mkdir -p "$CLAUDE_DIR/agents"
echo -e "${GREEN}  ✓ Created: $CLAUDE_DIR/agents${NC}"

# Copy agents
echo -e "\n${YELLOW}[4/6] Installing agents...${NC}"
if [ -d "$SCRIPT_DIR/agents" ]; then
    for agent in "$SCRIPT_DIR/agents"/*.md; do
        if [ -f "$agent" ]; then
            cp "$agent" "$CLAUDE_DIR/agents/"
            echo -e "${GREEN}  ✓ Installed: $(basename "$agent")${NC}"
        fi
    done
else
    echo -e "${RED}  ✗ Agents directory not found!${NC}"
    exit 1
fi

# Copy documentation
echo -e "\n${YELLOW}[5/6] Installing documentation...${NC}"
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
echo -e "\n${YELLOW}[6/6] Configuring settings...${NC}"
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
echo -e "  • Backup location: $BACKUP_DIR"

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

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a production-ready collection of 15 specialized AI agents, security configurations, and development tools for Claude Code. The repository is designed for distribution - users clone it and run installation scripts that copy agents to `~/.claude/agents/` and merge configuration files.

## Key Commands

### Installation & Verification
```bash
# Linux/Mac installation
chmod +x install.sh
./install.sh

# Windows installation (PowerShell)
.\install.ps1

# Verify installation in Claude Code
/agents
/agents refresh

# Test diagnostics
/doctor
```

### Development Workflow
```bash
# Test a single agent locally before committing
cp agents/agent-name.md ~/.claude/agents/
# Then invoke it in Claude Code to test

# Run with real scenarios to validate behavior
# Check tool restrictions work as expected
```

### Testing MCP Connections
```bash
# In Claude Code
/mcp
claude mcp list
```

## Architecture

### Core Structure

**Agents Directory (`agents/`)**: Contains 15 specialized agent definition files in YAML frontmatter + Markdown format. Each agent is completely self-contained and follows this structure:

```markdown
---
name: agent-name
description: When to use this agent (used by router for selection)
tools: Read, Glob, Grep, Edit, Bash
model: sonnet
---

# Identity
# Core Principles
# Workflow
# Best Practices
# Tool Usage
```

**Agent Categories**:
- Backend (4): python-architect, go-expert, node-engineer, backend-engineer
- Frontend (3): frontend-architect, astro-expert, ux-ui-designer
- Database (3): postgres-dba, mysql-expert, mongo-architect (require MCP)
- Security (2): security-engineer, secure-code-reviewer
- Infrastructure (1): powershell-automator
- Application (1): streamlit-expert
- Meta (1): prompt-engineer

**Configuration (`config/settings.json`)**: Template for security hooks and permissions that gets merged (not overwritten) during installation:
- PreToolUse hook: Validates bash commands for safety using Haiku model
- PostToolUse hook: Tracks file modifications
- Permission system: Defaults to allow Read, Glob, Grep only

**Documentation (`docs/`)**: Reference guides that get copied to `~/.claude/`:
- AGENT_TEAM_GUIDE.md: Complete agent reference and workflows
- integrate-trailofbits.md: Security skills integration guide

### Installation Flow

1. User clones repository → 2. Runs install script → 3. Script validates Claude Code is installed → 4. Creates timestamped backup of `~/.claude/` → 5. Copies `agents/*.md` to `~/.claude/agents/` → 6. Copies docs to `~/.claude/` → 7. Merges settings.json (preserves existing config) → 8. User verifies with `/agents` command

### Security Design

**Least Privilege Principle**: Each agent only has access to tools it needs. Read-only agents (reviewers, analyzers) only get Read, Grep, Glob. Code modification agents add Edit cautiously. System agents requiring Bash need strong justification.

**Hook System**: PreToolUse hook validates bash commands for destructive operations, credential exposure, and unknown network requests before execution. Uses fast Haiku model with 15s timeout.

**Safe Distribution**: .gitignore prevents committing credentials, .env files, private keys, and connection strings with passwords. All examples use placeholders.

## Agent Design Philosophy

**Specificity Over Generality**: Each agent has focused expertise in one domain. No generic "helper" agents. Router uses the description field to accurately determine which agent to invoke.

**Actionable Instructions**: Agents contain clear, concrete steps and workflows. They include "when NOT to use" guidance to prevent router confusion.

**Tool Scoping**: Tools list follows principle of least privilege. Database agents get MCP access, reviewers get read-only tools, architects get Edit + Bash when justified.

**Cognitive Protocol**: Many agents (especially python-architect) follow chain-of-thought pattern: analyze context → formulate plan → safety check → implement.

## Common Patterns

### Agent File Structure
All agents follow consistent sections: Identity → Core Principles/Standards → Workflow → Best Practices → Tool Usage. This helps users understand agent capabilities and LLM internalize the role.

### Testing Methodology
1. Copy agent to `~/.claude/agents/`
2. Verify with `/agents` command
3. Create sample files the agent would work with
4. Invoke and verify behavior matches description
5. Confirm tool restrictions are enforced
6. Security review: no hardcoded secrets, minimal permissions, no injection vulnerabilities

### Update Process
When repository updates: user runs `git pull` → re-runs install script → new backup created → agents overwritten with latest → settings.json preserved (only structure changes merged).

## Integration Points

**Trail of Bits Security Skills**: Repository includes integration guide for professional security skills marketplace. Essential skills: audit-context-building, differential-review, variant-analysis, fix-review.

**MCP Database Servers**: Database agents (postgres-dba, mysql-expert, mongo-architect) require MCP server configuration. Template provided for PostgreSQL, MySQL, and MongoDB connections. Users configure in `.mcp.json` (project-specific) or `~/.claude.json` (user-wide).

**Language Server Plugins**: Documentation recommends installing pyright-lsp, typescript-lsp, gopls-lsp for code intelligence. Not required but enhances agent capabilities.

## Important Constraints

**No Credential Commits**: Installation scripts, agent files, and documentation must never contain real credentials. Always use placeholders like `USERNAME:PASSWORD@localhost`.

**Settings Merge Logic**: Installation scripts detect existing `settings.json` and warn about manual merge requirement. Never overwrite user's existing hooks or permissions without consent.

**Cross-Platform Support**: Both install.sh (bash) and install.ps1 (PowerShell) must maintain feature parity. Color-coded output, error handling, and verification steps should match.

**Agent Naming Convention**: Use kebab-case, be specific (not generic), indicate role (architect/engineer/specialist/expert/reviewer).

## File Modification Guidelines

When modifying agents, preserve their structure and tool restrictions. When updating installation scripts, test on both platforms. When changing settings.json template, document what users need to merge manually.

Agent descriptions are critical - router uses them for selection. Make descriptions specific about technologies, patterns, and use cases. Avoid vague language like "helps with X" - instead use "specializes in Y when working with Z".

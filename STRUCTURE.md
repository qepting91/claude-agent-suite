# Repository Structure

This document describes the organization of the Claude Code Agent Suite repository.

## 📁 Directory Layout

```
claude-agent-suite/
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── CONTRIBUTING.md              # Contribution guidelines
├── STRUCTURE.md                 # This file
├── .gitignore                   # Git ignore rules
│
├── agents/                      # All agent definitions (15 files)
│   ├── astro-expert.md
│   ├── backend-engineer.md
│   ├── frontend-architect.md
│   ├── go-expert.md
│   ├── mongo-architect.md
│   ├── mysql-expert.md
│   ├── node-engineer.md
│   ├── postgres-dba.md
│   ├── powershell-automator.md
│   ├── prompt-engineer.md
│   ├── python-architect.md
│   ├── secure-code-reviewer.md
│   ├── security-engineer.md
│   ├── streamlit-expert.md
│   └── ux-ui-designer.md
│
├── config/                      # Configuration templates
│   └── settings.json           # Security hooks & permissions template
│
├── docs/                        # Documentation files
│   ├── AGENT_TEAM_GUIDE.md     # Complete agent reference
│   └── integrate-trailofbits.md # Security skills guide
│
├── install.sh                   # Linux/Mac installation script
└── install.ps1                  # Windows installation script
```

## 📄 File Descriptions

### Root Files

- **README.md** - Primary documentation with installation instructions
- **LICENSE** - MIT License for the project
- **CONTRIBUTING.md** - Guidelines for contributors
- **STRUCTURE.md** - This file (repository organization)
- **.gitignore** - Files to exclude from version control

### agents/

Contains all 15 specialized agent definition files. Each file follows the format:

```markdown
---
name: agent-name
description: When to use this agent
tools: List of allowed tools
model: sonnet or haiku
---

Agent instructions in markdown...
```

**Categories:**
- **Backend (4):** python-architect, go-expert, node-engineer, backend-engineer
- **Frontend (3):** frontend-architect, astro-expert, ux-ui-designer
- **Database (3):** postgres-dba, mysql-expert, mongo-architect
- **Security (2):** security-engineer, secure-code-reviewer
- **Infrastructure (1):** powershell-automator
- **Application (1):** streamlit-expert
- **Meta (1):** prompt-engineer

### config/

**settings.json** - Template configuration file containing:
- Permission system (allow/deny lists)
- PreToolUse hook for bash command validation
- PostToolUse hook for file modification tracking
- SessionStart hook

This file is **merged** during installation (not overwritten) to preserve user settings.

### docs/

**AGENT_TEAM_GUIDE.md** - Comprehensive reference guide:
- All agent descriptions and use cases
- Security configuration details
- MCP server setup instructions
- Workflow recommendations
- Best practices
- Quick command reference

**integrate-trailofbits.md** - Security skills integration guide:
- Trail of Bits marketplace setup
- Essential security skill descriptions
- Installation commands
- Security workflow examples
- Troubleshooting guide

### Installation Scripts

**install.sh** (Linux/Mac)
- Checks prerequisites
- Creates backup of existing configuration
- Copies agents to `~/.claude/agents/`
- Copies documentation to `~/.claude/`
- Merges settings.json
- Verifies installation

**install.ps1** (Windows/PowerShell)
- Same functionality as install.sh
- PowerShell-native implementation
- Color-coded output
- Error handling

## 🔄 Installation Flow

```
1. User clones repository
   ↓
2. User runs install.sh or install.ps1
   ↓
3. Script checks Claude Code is installed
   ↓
4. Script creates backup: ~/.claude.backup.TIMESTAMP
   ↓
5. Script creates directories if needed
   ↓
6. Script copies agents/*.md → ~/.claude/agents/
   ↓
7. Script copies docs/*.md → ~/.claude/
   ↓
8. Script merges config/settings.json → ~/.claude/settings.json
   ↓
9. Installation complete
   ↓
10. User opens Claude Code
   ↓
11. User runs /agents to verify
```

## 📦 What Gets Installed

After running the installation script, the user's system will have:

```
~/.claude/
├── agents/                          # 15 agent files copied here
│   ├── astro-expert.md
│   ├── backend-engineer.md
│   ├── ... (13 more agents)
│   └── ux-ui-designer.md
│
├── AGENT_TEAM_GUIDE.md             # Documentation copied here
├── integrate-trailofbits.md        # Documentation copied here
│
└── settings.json                    # Merged with existing (if present)
```

## 🔒 Security Considerations

### Files Excluded from Git

The `.gitignore` file prevents committing:
- Credentials (`.credentials.json`)
- Environment files (`*.env`)
- Private keys (`*.pem`, `*.key`)
- Local overrides (`*.local.*`)
- Database connection strings with passwords

### Safe to Commit

- Agent definition files (no secrets)
- Documentation (public information)
- Settings template (no credentials)
- Installation scripts (no sensitive data)

## 🛠️ Customization Points

Users can customize their installation:

1. **Per-Agent Basis:** Modify individual agent files in `~/.claude/agents/`
2. **Settings:** Edit `~/.claude/settings.json` for hooks and permissions
3. **Project-Specific:** Add `.claude/` directory in projects for local overrides
4. **MCP Connections:** Configure databases in `.mcp.json` (project) or `~/.claude.json` (user)

## 📊 Repository Stats

- **Total Agents:** 15
- **Configuration Files:** 1 (settings.json template)
- **Documentation Files:** 2 (AGENT_TEAM_GUIDE.md, integrate-trailofbits.md)
- **Installation Scripts:** 2 (install.sh, install.ps1)
- **Total Files:** ~23

## 🔄 Update Process

When the repository is updated:

1. User runs `git pull origin main`
2. User re-runs installation script
3. Script creates new backup
4. Script copies updated agents (overwrites)
5. Script preserves user's settings.json modifications

## 🎯 Design Philosophy

**Modular:** Each agent is a separate file for easy customization

**Safe:** Installation creates backups before making changes

**Flexible:** Settings are merged, not overwritten

**Documented:** Comprehensive guides included

**Secure:** No secrets in repository, proper .gitignore

**Cross-Platform:** Works on Windows, Linux, and Mac

---

**For more information, see:**
- Installation: [README.md](README.md)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)
- Agent Reference: [docs/AGENT_TEAM_GUIDE.md](docs/AGENT_TEAM_GUIDE.md)

# Claude Code Professional Agent Suite

A comprehensive, production-ready collection of specialized AI agents, security skills, and development tools for Claude Code.

**Repository:** https://github.com/qepting91/claude-agent-suite

## 🎯 What's Included

### 15 Specialized Agents
- **Backend:** Python, Go, Node.js, Generic Backend
- **Frontend:** HTML/CSS, AstroJS, UX/UI Design
- **Database:** PostgreSQL, MySQL, MongoDB (with MCP integration)
- **Security:** Security Engineering, Secure Code Review
- **Infrastructure:** PowerShell Automation
- **Application:** Streamlit Development
- **Meta:** Prompt Engineering

### Security & Best Practices
- Pre-configured security hooks for bash command validation
- Post-tool-use hooks for file modification tracking
- Permission system with least-privilege defaults
- Integration guide for Trail of Bits security skills
- OWASP and CWE-aligned security patterns

### MCP Server Configurations
- PostgreSQL connection template
- MySQL connection template
- MongoDB connection template
- Filesystem access configuration

### Comprehensive Documentation
- Complete agent reference guide
- Security skills integration guide
- Best practices for agent development
- Workflow recommendations

### Modern Build System
- **Jinja2-based template compilation** with reusable skill components
- **Automated validation**: Token budgets, bash syntax, dangerous commands
- **Comprehensive test suite** with >90% coverage (pytest)
- **CI/CD pipeline** on 3 platforms, 4 Python versions (GitHub Actions)
- **Quality assurance**: Linters (black, isort, flake8), type checking (mypy)

---

## 🔄 CI/CD & Compliance

This project includes enterprise-grade CI/CD with automated testing, security scanning, and compliance auditing.

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `test.yml` | Push/PR | Multi-platform tests (Ubuntu, Windows, macOS) |
| `security.yml` | Push/PR | Security scanning (Semgrep, Bandit, pip-audit) |
| `release.yml` | Tags (v*) | Build, test, package, and publish releases |
| `audit-log.yml` | After release | Archive evidence to immutable branch |

### Code Analysis Checks

Every push and PR runs comprehensive code analysis:

**Static Analysis:**
- **Semgrep** - SAST scanning for security vulnerabilities (OWASP patterns)
- **Bandit** - Python-specific security linter
- **Ruff** - Fast Python linter (replaces flake8)

**Dependency Security:**
- **pip-audit** - Scans for known CVEs in Python dependencies
- **Safety** - Additional vulnerability database checks

**Code Quality:**
- **Black** - Code formatting
- **isort** - Import sorting
- **mypy** - Type checking
- **flake8** - Style guide enforcement

**Build Validation:**
- Token budget enforcement (max 2500 tokens per agent)
- Bash syntax validation in code blocks
- Dangerous command detection (rm -rf /, chmod 777, etc.)
- YAML frontmatter validation

### Intelligence Testing (Promptfoo)

On tagged releases, agents are tested against real AI models:

```bash
# Run locally
make eval

# Configuration
eval/promptfoo.yaml         # Test configuration
eval/datasets/smoke-tests.jsonl  # Test cases
```

Tests validate agents can correctly handle:
- Python architecture questions
- Security code review scenarios
- API design best practices

### Automated Releases

Create a release with:

```bash
# Tag and push
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Or use Makefile helper
make release-tag V=1.0.0
```

**Release workflow:**
1. ✅ Builds all 16 agents from templates
2. ✅ Runs full test suite
3. ✅ Runs intelligence tests (optional, if API key set)
4. ✅ Creates `claude-agents-vX.X.X.zip` package
5. ✅ Publishes to GitHub Releases
6. ✅ Archives audit evidence

### Immutable Audit Trail

Every release creates a SHA256 evidence manifest on the `evidence-audit` branch:

```json
{
  "metadata": {
    "timestamp": "2026-02-05T21:00:00Z",
    "git_sha": "abc123...",
    "git_tag": "v0.0.5"
  },
  "artifacts": {
    "agents": [
      {"file": "python-architect.md", "sha256": "e3b0c44..."}
    ],
    "security_config": {
      "dangerous_commands_sha256": "..."
    }
  }
}
```

**Branch Protection:** Enable protection on `evidence-audit` (no force pushes, no deletions) for compliance.

### Required Secrets

| Secret | Required | Purpose |
|--------|----------|---------|
| `GITHUB_TOKEN` | Auto | Provided by GitHub, used for releases |
| `ANTHROPIC_API_KEY` | Optional | For Promptfoo intelligence tests |

---

## 🚀 Quick Start

### Prerequisites

1. **Claude Code CLI** (latest version)
   ```bash
   # Check if installed
   claude --version

   # If not installed:
   # Windows: irm https://claude.ai/install.ps1 | iex
   # Mac/Linux: curl -fsSL https://claude.ai/install.sh | bash
   ```

2. **Git** (for cloning this repository)

3. **Node.js/npm** (for language servers and MCP)
   ```bash
   node --version
   npm --version
   ```

4. **Language Server Binaries** (optional, for code intelligence)
   ```bash
   # Python
   npm install -g pyright

   # TypeScript/JavaScript
   npm install -g typescript-language-server typescript

   # Go
   go install golang.org/x/tools/gopls@latest
   ```

---

## 💻 System Requirements

### Minimum Requirements
- **Disk Space:** 2MB free in home directory (includes backup space)
- **Permissions:** Write access to `~/.claude` directory
- **OS Support:**
  - Linux: Ubuntu 20.04+, Debian 11+, RHEL 8+
  - macOS: 12.0 (Monterey)+
  - Windows: 10/11 with PowerShell 5.1+

### Software Dependencies
- **Required:** Claude Code CLI (latest version), Git 2.20+
- **Optional:** Node.js 18+ & npm 9+ (for MCP database servers)

### Compatibility Notes
- **Windows:** PowerShell 7+ recommended (5.1 minimum)
- **macOS:** Apple Silicon (M1/M2/M3) fully supported
- **WSL:** Windows Subsystem for Linux supported via `install.sh`

---

## 📥 Installation

### Automated Installation (Recommended)

#### Windows (PowerShell)
```powershell
# Clone this repository
git clone https://github.com/qepting91/claude-agent-suite.git
cd claude-agent-suite

# Run installation script
.\install.ps1
```

#### Linux/Mac (Bash)
```bash
# Clone this repository
git clone https://github.com/qepting91/claude-agent-suite.git
cd claude-agent-suite

# Make script executable and run
chmod +x install.sh
./install.sh
```

The installation script will:
1. ✅ Backup your existing `.claude` configuration
2. ✅ Copy agents to `~/.claude/agents/`
3. ✅ Copy documentation files
4. ✅ Merge settings (preserving your existing configuration)
5. ✅ Verify installation

### Manual Installation

If you prefer manual control:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/qepting91/claude-agent-suite.git
   cd claude-agent-suite
   ```

2. **Backup your existing configuration:**
   ```bash
   # Windows (PowerShell)
   Copy-Item -Recurse $HOME\.claude $HOME\.claude.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')

   # Linux/Mac
   cp -r ~/.claude ~/.claude.backup.$(date +%Y%m%d-%H%M%S)
   ```

3. **Build agents (required for manual install):**
   ```bash
   # Install build dependencies
   pip install -r requirements.txt

   # Compile templates to production agents
   python scripts/build.py --verbose
   ```

4. **Copy compiled agents:**
   ```bash
   # Windows (PowerShell)
   Copy-Item -Recurse dist\agents\* $HOME\.claude\agents\

   # Linux/Mac
   cp -r dist/agents/* ~/.claude/agents/
   ```

5. **Copy documentation:**
   ```bash
   # Windows (PowerShell)
   Copy-Item docs\* $HOME\.claude\

   # Linux/Mac
   cp docs/* ~/.claude/
   ```

5. **Merge settings (carefully):**
   - Review `config/settings.json` from this repository
   - Manually merge the hooks and permissions into your `~/.claude/settings.json`
   - Don't overwrite your entire settings file!

---

## 🔧 Post-Installation Configuration

### 1. Verify Agent Installation

Open Claude Code and run:
```bash
/agents
```

You should see all 15 agents listed.

### 2. Install Code Intelligence Plugins (Recommended)

```bash
# In Claude Code
/plugin install pyright-lsp@claude-plugins-official
/plugin install typescript-lsp@claude-plugins-official
/plugin install gopls-lsp@claude-plugins-official
```

### 3. Configure MCP Database Connections (Optional)

**For Project-Specific Databases:**
Create `.mcp.json` in your project root:
```json
{
  "mcpServers": {
    "postgresql": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/dbname"]
    }
  }
}
```

See `AGENT_TEAM_GUIDE.md` for detailed MCP configuration instructions.

### 4. Install Trail of Bits Security Skills (Highly Recommended)

```bash
# In Claude Code
/plugin marketplace add trailofbits/skills

# Install essential security skills
/plugin install trailofbits/skills/plugins/differential-review
/plugin install trailofbits/skills/plugins/audit-context-building
/plugin install trailofbits/skills/plugins/variant-analysis
```

See `integrate-trailofbits.md` for complete security skills setup.

---

## 📚 Documentation

After installation, these guides are available in `~/.claude/`:

1. **AGENT_TEAM_GUIDE.md** - Complete agent reference
2. **integrate-trailofbits.md** - Security skills integration

---

## 🎓 Usage Examples

### Secure Code Review
```bash
/secure-code-reviewer @path/to/file.py
```

### Backend Development
```bash
/backend-engineer "Design a RESTful API for user management"
/python-architect @api/users.py
```

### Frontend Design
```bash
/ux-ui-designer "Review the checkout flow for accessibility"
/frontend-architect @components/checkout.html
```

### Database Operations with MCP
```bash
/postgres-dba "Find slow queries and suggest indexes"
```

---

## 🔒 Security Features

- **PreToolUse Hook:** Validates bash commands for safety
- **PostToolUse Hook:** Tracks file modifications
- **Security Agents:** Threat modeling and vulnerability detection
- **Trail of Bits Integration:** Professional security skills

---

## 🛠️ Customization

### Adding Your Own Agents

Create `~/.claude/agents/my-agent.md`:
```yaml
---
name: my-agent
description: When to use this agent
tools: Read, Grep, Glob
model: sonnet
---

Your agent instructions here
```

Refresh: `/agents refresh`

---

## 🔄 Updating

### Standard Update
```bash
cd claude-agent-suite
git pull origin main
./install.sh  # or install.ps1 on Windows
```

### ⚠️ Important: Customized Agents
**The installer overwrites all default agents.** If you customized any of the 15 included agents:

1. **Backup custom agents first:**
   ```bash
   # Linux/Mac
   cp ~/.claude/agents/[your-modified-agent].md ~/backup/

   # Windows (PowerShell)
   Copy-Item $HOME\.claude\agents\[your-modified-agent].md $HOME\backup\
   ```

2. **Run update:**
   ```bash
   ./install.sh  # or install.ps1 on Windows
   ```

3. **Restore or merge custom changes:**
   ```bash
   # Option 1: Restore your version (overwrites update)
   cp ~/backup/[agent].md ~/.claude/agents/

   # Option 2: Manually merge changes
   diff ~/backup/[agent].md ~/.claude/agents/[agent].md
   ```

**Best Practice:** Use unique names for custom agents (e.g., `my-python-expert.md`) to avoid overwrites during updates.

---

## 🐛 Troubleshooting

### Installation Issues

#### Error: "Agents directory not found"
**Cause:** Repository downloaded as ZIP instead of git clone.

**Solution:**
1. Delete the downloaded ZIP directory
2. Clone properly: `git clone https://github.com/qepting91/claude-agent-suite.git`
3. Re-run installation script

#### Error: "Permission denied"
**Cause:** Insufficient permissions to home directory.

**Solution (Linux/Mac):**
```bash
sudo chown -R $USER:$USER ~/.claude
chmod 755 ~/.claude
```

**Solution (Windows):** Run PowerShell as Administrator

#### Warning: "Not a git repository"
**Impact:** Future updates via `git pull` will not work.

**Prevention:** Always clone the repository with git instead of downloading as ZIP.

#### Issue: "Agent count: 0" after installation
**Diagnosis:**
```bash
# Check if files actually exist
ls ~/.claude/agents/  # Linux/Mac
dir $HOME\.claude\agents\  # Windows
```

**Solution:** Re-run installer. If problem persists, check disk space and permissions.

#### Error: "Agent count mismatch"
**Cause:** Corrupt repository download or interrupted installation.

**Solution:**
1. Delete the repository directory
2. Fresh clone: `git clone https://github.com/qepting91/claude-agent-suite.git`
3. Re-run installer

### Runtime Issues

#### Agents not showing in /agents list
**Diagnosis & Solutions:**
1. Run `/agents refresh` in Claude Code
2. Verify files exist: `ls ~/.claude/agents/*.md` (should show 15 files)
3. Check frontmatter syntax: `head -5 ~/.claude/agents/python-architect.md` (should start with `---`)
4. Restart Claude Code completely

#### MCP database connections failing
**Diagnosis:**
```bash
/mcp
claude mcp list
```

**Common Issues & Solutions:**
- Database credentials incorrect → Check connection strings in `.mcp.json`
- `npx` not in PATH → Verify Node.js installation: `node --version`
- Port already in use → Check with `netstat -an | grep 5432` (adjust port)
- MCP server not installed → Run `npx -y @modelcontextprotocol/server-postgres --version`

### Rollback & Recovery

#### Restore previous configuration
The installer creates timestamped backups. To restore:

```bash
# Find your backup
ls -d ~/.claude.backup.*

# Restore (replace timestamp with yours)
rm -rf ~/.claude
mv ~/.claude.backup.20260202-143022 ~/.claude
```

**Windows:**
```powershell
# Find backup
Get-ChildItem $HOME\.claude.backup.*

# Restore
Remove-Item -Recurse $HOME\.claude
Move-Item $HOME\.claude.backup.20260202-143022 $HOME\.claude
```

#### Complete uninstall
```bash
# Backup first (optional)
cp -r ~/.claude ~/.claude.manual-backup

# Remove everything
rm -rf ~/.claude
```

**Windows:**
```powershell
Copy-Item -Recurse $HOME\.claude $HOME\.claude.manual-backup
Remove-Item -Recurse $HOME\.claude
```

### Diagnostics Commands

```bash
# Verify installation
/agents                           # List all agents
/doctor                          # Run diagnostics
claude --version                 # Check CLI version

# Check file counts
ls ~/.claude/agents/*.md | wc -l # Should be 15

# Validate agent format
head -10 ~/.claude/agents/python-architect.md
```

---

## ❓ Frequently Asked Questions

### Installation

**Q: Will this affect my current agents?**
A: No. The installer creates a timestamped backup before making any changes. Your original configuration is preserved.

**Q: How much disk space is required?**
A: Approximately 2MB total (agents + documentation + backup space).

**Q: Can I customize the included agents?**
A: Yes, but be aware that updates will overwrite your changes. **Recommended solution:** Copy the agent to a new file with a unique name (e.g., `my-python-architect.md`) and customize that version instead.

**Q: Do I need all 15 agents?**
A: No. After installation, you can delete any agents you don't need from `~/.claude/agents/`.

**Q: Can I re-run the installer safely?**
A: Yes. The installer is idempotent and creates a new timestamped backup each time.

**Q: Do I need to restart Claude Code after installation?**
A: No, but you should run `/agents refresh` to reload the agent list.

**Q: What if the installation fails midway?**
A: The installer will attempt to automatically rollback to your backup. If that fails, you can manually restore from `~/.claude.backup.[timestamp]`.

### Configuration

**Q: How do I add my own agents?**
A: Create a `.md` file in `~/.claude/agents/` with YAML frontmatter. See the CONTRIBUTING.md guide for the required format.

**Q: Can I modify the security hooks?**
A: Yes. Edit `~/.claude/settings.json` to customize the `hooks` section. See `config/settings.json` for examples.

**Q: How do I configure MCP database connections?**
A: Create `.mcp.json` in your project root or configure in `~/.claude.json` for user-wide settings. See AGENT_TEAM_GUIDE.md for detailed instructions.

### Updates

**Q: How do I update without losing customizations?**
A:
1. Backup any customized agents: `cp ~/.claude/agents/[modified-agent].md ~/backup/`
2. Run the installer: `./install.sh`
3. Restore customizations: `cp ~/backup/[agent].md ~/.claude/agents/`

Alternatively, use unique filenames for custom agents (e.g., `my-custom-python.md`) to avoid conflicts.

**Q: What if `git pull` fails with "not a git repository"?**
A: The repository was downloaded as a ZIP file. Delete the directory and clone properly:
```bash
git clone https://github.com/qepting91/claude-agent-suite.git
```

**Q: How often should I update?**
A: Check the repository weekly for security patches and new features. Subscribe to GitHub releases for notifications.

### Security

**Q: What do the security hooks do?**
A: The PreToolUse hook validates bash commands before execution (checking for destructive operations, credential exposure, etc.). The PostToolUse hook tracks file modifications. See `config/settings.json` for details.

**Q: Can I disable the security hooks?**
A: Yes, but it's not recommended. Remove the `hooks` section from `~/.claude/settings.json` to disable.

**Q: Are the agents safe to use?**
A: Yes. All agents follow the principle of least privilege - they only have access to the minimum tools needed. Security agents are read-only by default.

### Usage

**Q: Which agent should I use for [task]?**
A: Use `/agents` to see the full list with descriptions. The router will automatically select the best agent based on your request.

**Q: Can I use multiple agents together?**
A: Yes. You can invoke different agents for different parts of a task, or use one agent's output as input to another.

**Q: Do the database agents require databases to be running?**
A: The postgres-dba, mysql-expert, and mongo-architect agents require MCP server connections. Other agents work without any external dependencies.

---

## 📊 What Gets Installed

The installation process compiles templates and installs production agents:

```
Build Process:
  src/agents/*.md.j2 → [scripts/build.py] → dist/agents/*.md → ~/.claude/agents/

~/.claude/
├── agents/                          # 15 compiled agents
│   ├── python-architect.md          # From dist/agents/ (compiled from src/agents/python-architect.md.j2)
│   ├── go-expert.md
│   ├── node-engineer.md
│   ├── backend-engineer.md
│   ├── frontend-architect.md
│   ├── astro-expert.md
│   ├── ux-ui-designer.md
│   ├── streamlit-expert.md
│   ├── powershell-automator.md
│   ├── postgres-dba.md
│   ├── mysql-expert.md
│   ├── mongo-architect.md
│   ├── security-engineer.md
│   ├── secure-code-reviewer.md
│   └── prompt-engineer.md
│
├── AGENT_TEAM_GUIDE.md             # Complete reference
├── integrate-trailofbits.md        # Security skills guide
└── settings.json                    # Hooks merged (preserves existing config)
```

**Note**: Users receive compiled agents from `dist/agents/`, not source templates from `src/agents/`.

---

## 🧪 Development & Testing

### Project Architecture

This project uses a **template-based build system** to compile specialized AI agents:

**Architecture Overview**:
```
Development Flow:
  src/agents/*.md.j2  →  scripts/build.py  →  dist/agents/*.md  →  ~/.claude/agents/
  (edit these)           (compiler)           (generated)         (user installation)
```

**Directory Structure**:
```
src/agents/          # Source templates (edit these) - Jinja2 templates with includes
src/skills/          # Reusable components - Shared patterns via {% include %}
scripts/build.py     # Build system - Jinja2 compiler + validation
dist/agents/         # Compiled output (generated) - Production-ready agents
agents/              # Legacy (will be removed) - Old static files
tests/               # Test suite - Pytest unit + integration tests
config/              # Build configuration - Validation rules, dangerous commands
```

### Build System

The build system compiles templates and validates output:

```bash
# Build all agents from templates
python scripts/build.py

# Build with verbose output
python scripts/build.py --verbose

# Validate templates without building
python scripts/build.py --validate-only
```

**What the build system does**:
1. Discovers templates in `src/agents/*.md.j2`
2. Renders Jinja2 templates with variables and includes
3. Validates frontmatter (required fields, valid model)
4. Enforces token budget (max 2500 tokens per agent)
5. Validates bash syntax in code blocks
6. Detects dangerous command patterns (rm -rf /, chmod 777, etc.)
7. Writes production agents to `dist/agents/*.md`
8. Reports statistics and errors

### Running Tests

```bash
# Install test dependencies
pip install -r requirements.txt

# Run all tests
pytest

# Run with coverage report
pytest --cov=scripts --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Using Make (Linux/Mac)

```bash
# Show all available commands
make help

# Run tests
make test

# Build agents
make build

# Run code linters
make lint
```

See `tests/README.md` for detailed testing documentation.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your agent/skill with documentation
4. **Run tests**: `pytest` (all tests must pass)
5. **Validate build**: `python scripts/build.py --validate-only`
6. Submit a pull request

### Agent Development Workflow

**Important**: Always edit source templates in `src/agents/`, never compiled output in `dist/agents/`.

1. **Edit templates**: `src/agents/*.md.j2` (Jinja2 templates)
2. **Create skills** (optional): `src/skills/category/module.md` (reusable components)
3. **Build**: `python scripts/build.py --verbose` (compile templates)
4. **Test output**: Review `dist/agents/*.md` (compiled agents)
5. **Test locally** (optional): `cp dist/agents/agent-name.md ~/.claude/agents/`
6. **Run tests**: `pytest` (all tests must pass)
7. **Validate build**: `python scripts/build.py --validate-only`
8. **Commit source only**: `git add src/agents/` (never commit `dist/` directory)
9. **Submit PR**: GitHub Actions will validate your changes

### What to Commit

**DO commit**:
- ✅ `src/agents/*.md.j2` (source templates)
- ✅ `src/skills/**/*.md` (reusable components)
- ✅ `tests/**/*.py` (test files)
- ✅ `scripts/build.py` (build system changes)
- ✅ Documentation updates (README, CLAUDE.md, etc.)

**DO NOT commit**:
- ❌ `dist/agents/*.md` (generated files, git-ignored)
- ❌ `.coverage`, `htmlcov/` (test outputs, git-ignored)
- ❌ `__pycache__/`, `*.pyc` (Python cache, git-ignored)

**Why?** The `dist/` directory contains build artifacts that can be regenerated from source. Committing them would clutter git history and cause merge conflicts.

---

## 📄 License

MIT License

---

## 🙏 Acknowledgments

- **Anthropic** - Claude Code platform
- **Trail of Bits** - Security skills marketplace
- **MCP Community** - Database server implementations

---

## 📞 Support

- **Documentation:** See `AGENT_TEAM_GUIDE.md`
- **Claude Code Docs:** https://code.claude.com/docs
- **Issues:** https://github.com/qepting91/claude-agent-suite/issues

---

**Version:** 1.0.0
**Last Updated:** 2026-02-02
**Status:** ✅ Production Ready

---

⭐ **Star this repository if you find it helpful!**

Made with ❤️ for the Claude Code community by [@qepting91](https://github.com/qepting91)

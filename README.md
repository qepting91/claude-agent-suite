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

3. **Copy agents:**
   ```bash
   # Windows (PowerShell)
   Copy-Item -Recurse agents\* $HOME\.claude\agents\

   # Linux/Mac
   cp -r agents/* ~/.claude/agents/
   ```

4. **Copy documentation:**
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

```bash
cd claude-agent-suite
git pull origin main
./install.sh  # or install.ps1 on Windows
```

---

## 🐛 Troubleshooting

### Agents Not Showing Up
```bash
/agents refresh
```

### MCP Servers Not Connecting
```bash
/mcp
claude mcp list
```

### Run Diagnostics
```bash
/doctor
```

---

## 📊 What Gets Installed

```
~/.claude/
├── agents/                          (15 specialized agents)
│   ├── python-architect.md
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
├── AGENT_TEAM_GUIDE.md             (Complete reference)
├── integrate-trailofbits.md        (Security skills guide)
└── (settings.json hooks merged)
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your agent/skill with documentation
4. Test thoroughly
5. Submit a pull request

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

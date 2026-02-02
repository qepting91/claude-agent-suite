# Claude Code Agent Team - Complete Setup Guide

## 📋 Overview

This document describes your complete Claude Code configuration with specialized agents, skills, MCP servers, and security tools following industry best practices.

---

## 🤖 Global Agent Team (15 Agents)

### Backend Engineering (4 agents)
1. **python-architect** - Modern Python (3.10+), asyncio, type-safe development
2. **go-expert** - Go concurrency, goroutines, idiomatic patterns
3. **node-engineer** - Node.js runtime, async/await, npm ecosystem
4. **backend-engineer** - Generic backend: APIs, databases, caching, distributed systems

### Frontend & UI (3 agents)
5. **frontend-architect** - Semantic HTML5, CSS3 Grid/Flexbox, accessibility
6. **astro-expert** - AstroJS, SSG, Islands Architecture
7. **ux-ui-designer** - User-centered design, WCAG accessibility, design systems

### Application Development (1 agent)
8. **streamlit-expert** - Streamlit dashboards, caching, session state

### Infrastructure & Automation (1 agent)
9. **powershell-automator** - PowerShell scripting, Windows automation, object-oriented pipelining

### Database Specialists (3 agents with MCP access)
10. **postgres-dba** - PostgreSQL query optimization, schema design
11. **mysql-expert** - MySQL InnoDB internals, performance tuning
12. **mongo-architect** - MongoDB NoSQL design, Aggregation Framework

### Security Engineering (2 agents)
13. **security-engineer** - Threat modeling, secure architecture, OWASP Top 10
14. **secure-code-reviewer** - Vulnerability detection, security anti-patterns, differential analysis

### Meta-Agent (1 agent)
15. **prompt-engineer** - LLM prompt optimization, agent instruction refinement

---

## 🛠️ Skills (Current: 4)

### Built-in Skills
1. **deploy-check** - Pre-deployment validation
2. **fix-issue** - Systematic issue resolution
3. **generate-tests** - Test generation
4. **review-code** - Code review workflow

### Recommended Security Skills (Trail of Bits)
*See "Trail of Bits Integration" section below*

---

## 🔌 MCP Servers (4 Connected)

### Database Connections
1. **postgresql** - `@modelcontextprotocol/server-postgres`
   - Connection: `postgresql://localhost:5432/mydb`
   - Status: ✅ Connected

2. **mysql** - `mcp-server-mysql`
   - Auto-configured via environment variables
   - Status: ✅ Connected

3. **mongodb** - `mongodb-mcp-server`
   - Connection: `mongodb://localhost:27017`
   - Status: ✅ Connected

### File System
4. **filesystem** - `@modelcontextprotocol/server-filesystem`
   - Path: `C:\Users\qepti\Documents\pythonscripts`
   - Status: ✅ Connected

---

## 🔒 Security Configuration

### Permission System (settings.json)
```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": []
  }
}
```

### PreToolUse Hook - Bash Command Safety
- **Purpose:** Validates bash commands before execution
- **Checks:**
  1. Destructive operations (rm -rf, git reset --hard)
  2. Credential exposure
  3. Network requests to unknown hosts
- **Model:** Haiku (fast validation)
- **Timeout:** 15 seconds

### PostToolUse Hook - File Modification Tracking
- **Purpose:** Notification after Edit/Write operations
- **Use Case:** Trigger formatting, linting, or audit logging

---

## 📦 Trail of Bits Security Skills Integration

### Step 1: Add the Marketplace

```bash
# Add Trail of Bits official marketplace
/plugin marketplace add trailofbits/skills
```

### Step 2: Install Essential Security Skills

Based on your needs, install these high-priority skills:

#### Core Security Review Skills
```bash
# Foundation: Deep context building for security analysis
/plugin install trailofbits/skills/plugins/audit-context-building

# Differential code review with risk-based prioritization
/plugin install trailofbits/skills/plugins/differential-review

# Validate security fixes actually resolve issues
/plugin install trailofbits/skills/plugins/fix-review

# Find similar vulnerabilities after identifying a pattern
/plugin install trailofbits/skills/plugins/variant-analysis
```

#### Static Analysis & Detection
```bash
# Integration with CodeQL, Semgrep, SARIF
/plugin install trailofbits/skills/plugins/static-analysis

# Test-driven Semgrep rule creation
/plugin install trailofbits/skills/plugins/semgrep-rule-creator

# Dangerous fail-open default detection
/plugin install trailofbits/skills/plugins/insecure-defaults
```

#### Specialized Security
```bash
# Timing side-channel vulnerability detection
/plugin install trailofbits/skills/plugins/constant-time-analysis

# Smart contract security (if applicable)
/plugin install trailofbits/skills/plugins/building-secure-contracts

# Property-based testing
/plugin install trailofbits/skills/plugins/property-based-testing
```

#### Development Best Practices
```bash
# Secure Python development
/plugin install trailofbits/skills/plugins/modern-python

# Testing methodologies
/plugin install trailofbits/skills/plugins/testing-handbook-skills

# Clarify ambiguous requirements
/plugin install trailofbits/skills/plugins/ask-questions-if-underspecified
```

### Step 3: Verify Installation

```bash
# List installed plugins
/plugin menu

# Check available skills
/skills
```

---

## 🎯 Recommended Workflows

### Secure Code Review Workflow
```
1. /secure-code-reviewer - Initial security scan
2. /trailofbits:differential-review - Deep change analysis
3. /trailofbits:variant-analysis - Find similar issues
4. /trailofbits:static-analysis - Automated tool scanning
5. /trailofbits:fix-review - Validate remediation
```

### New Feature Development
```
1. /ux-ui-designer - Design user experience
2. /backend-engineer - Plan API architecture
3. /python-architect (or relevant lang) - Implement
4. /generate-tests - Create test coverage
5. /security-engineer - Security review
6. /review-code - Final code review
```

### Database Optimization
```
1. /postgres-dba (or mysql/mongo) - Analyze query performance
2. Use MCP tools to run EXPLAIN ANALYZE
3. /backend-engineer - Implement caching strategy
```

---

## 📚 Best Practices Summary

### Agent Design Principles
✅ **Single Responsibility:** Each agent has one clear expertise domain
✅ **Strict Tool Scoping:** Agents only have tools they need (security)
✅ **Read-Only by Default:** Review agents use Read/Grep/Glob, not Edit/Write
✅ **Model Selection:** Sonnet for complex reasoning, Haiku for fast operations
✅ **MCP Tool Isolation:** Database agents only see their specific MCP tools

### Skill Organization
✅ **Task-Based Naming:** Use gerund form (reviewing-code, deploying-app)
✅ **Progressive Disclosure:** Keep SKILL.md concise, link to detailed references
✅ **Context Isolation:** Use `context: fork` for heavy research skills
✅ **Safety Gates:** `disable-model-invocation: true` for destructive operations

### Security Hardening
✅ **Least Privilege:** Only grant permissions explicitly needed
✅ **Defense in Depth:** Multiple security layers (hooks + permissions + agents)
✅ **Secrets Management:** Never hardcode credentials (use env vars or MCP)
✅ **Input Validation:** Security agents enforce validation at all boundaries
✅ **Audit Logging:** Track sensitive operations via hooks

---

## 🔧 Maintenance Tasks

### Monthly
- [ ] Review installed plugins: `/plugin menu`
- [ ] Update Trail of Bits skills: Check for new releases
- [ ] Audit MCP connections: `/mcp` to verify status
- [ ] Review permission logs: Check for blocked operations

### Quarterly
- [ ] Agent effectiveness review: Are agents being invoked correctly?
- [ ] Skill usage analysis: Which skills are most valuable?
- [ ] Security configuration audit: Update threat models

### As Needed
- [ ] Add project-specific agents to `.claude/agents/`
- [ ] Create custom skills for team workflows
- [ ] Configure project-scoped MCP servers in `.mcp.json`

---

## 📖 Reference Documentation

### Official Resources
- **Claude Code Docs:** https://code.claude.com/docs
- **MCP Specification:** https://modelcontextprotocol.io
- **Trail of Bits Skills:** https://github.com/trailofbits/skills
- **Anthropic Best Practices:** https://www.anthropic.com/engineering/claude-code-best-practices

### Key Concepts
- **Scope Hierarchy:** Managed > CLI > Local > Project > User
- **Permission Modes:** allow, deny, ask (deny always wins)
- **Tool Scoping:** Use wildcards (`mcp__postgresql__*`) for efficiency
- **Agent Invocation:** Claude auto-selects based on description embeddings

---

## 🚀 Quick Commands Reference

```bash
# Agent Management
/agents                    # List all agents
/agents refresh            # Reload agent definitions

# Skill Management
/skills                    # List all skills
/<skill-name>              # Invoke a skill

# Plugin Management
/plugin menu               # Browse plugins
/plugin install <name>     # Install plugin
/plugin uninstall <name>   # Remove plugin

# MCP Management
/mcp                       # View MCP server status
claude mcp list            # CLI: List servers
claude mcp add <name>      # CLI: Add server
claude mcp remove <name>   # CLI: Remove server

# Configuration
/permissions               # View/modify permissions
/settings                  # View settings
/doctor                    # System diagnostics
```

---

## 🎓 Learning Resources

### For Security Engineering
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- CWE Top 25: https://cwe.mitre.org/top25/
- Trail of Bits Security Handbook: https://appsec.guide/

### For Backend Engineering
- API Design: REST API Best Practices
- Database: Use The Index, Luke (https://use-the-index-luke.com/)
- Distributed Systems: Martin Kleppmann's "Designing Data-Intensive Applications"

### For Frontend/UX
- WCAG 2.2 Guidelines: https://www.w3.org/WAI/WCAG22/quickref/
- Design Systems: Material Design, Apple HIG, Ant Design
- A11y Project: https://www.a11yproject.com/

---

## 📝 Version History

- **2026-02-02:** Initial setup with 15 agents, 4 MCP servers, security hooks
- **2026-02-02:** Added security-engineer, secure-code-reviewer, ux-ui-designer, backend-engineer
- **2026-02-02:** Integrated Trail of Bits marketplace

---

**Status:** ✅ Production-Ready
**Last Updated:** 2026-02-02
**Maintained By:** [Your Name/Team]

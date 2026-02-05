---
sidebar_position: 3
---

# Agent Team Guide

Complete reference for Claude Code Agent Suite with 15 specialized agents, skills, MCP servers, and security tools.

## 🤖 Global Agent Team (15 Agents)

### Backend Engineering (4 agents)
| Agent | Specialty |
|-------|-----------|
| **python-architect** | Modern Python (3.10+), asyncio, type-safe development |
| **go-expert** | Go concurrency, goroutines, idiomatic patterns |
| **node-engineer** | Node.js runtime, async/await, npm ecosystem |
| **backend-engineer** | Generic backend: APIs, databases, caching, distributed systems |

### Frontend & UI (3 agents)
| Agent | Specialty |
|-------|-----------|
| **frontend-architect** | Semantic HTML5, CSS3 Grid/Flexbox, accessibility |
| **astro-expert** | AstroJS, SSG, Islands Architecture |
| **ux-ui-designer** | User-centered design, WCAG accessibility, design systems |

### Application Development (1 agent)
| Agent | Specialty |
|-------|-----------|
| **streamlit-expert** | Streamlit dashboards, caching, session state |

### Infrastructure & Automation (1 agent)
| Agent | Specialty |
|-------|-----------|
| **powershell-automator** | PowerShell scripting, Windows automation |

### Database Specialists (3 agents with MCP access)
| Agent | Specialty |
|-------|-----------|
| **postgres-dba** | PostgreSQL query optimization, schema design |
| **mysql-expert** | MySQL InnoDB internals, performance tuning |
| **mongo-architect** | MongoDB NoSQL design, Aggregation Framework |

### Security Engineering (2 agents)
| Agent | Specialty |
|-------|-----------|
| **security-engineer** | Threat modeling, secure architecture, OWASP Top 10 |
| **secure-code-reviewer** | Vulnerability detection, security anti-patterns |

### Meta-Agent (1 agent)
| Agent | Specialty |
|-------|-----------|
| **prompt-engineer** | LLM prompt optimization, agent instruction refinement |

---

## 🔒 Security Configuration

### Permission System
```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": []
  }
}
```

### PreToolUse Hook - Bash Command Safety
- Validates bash commands before execution
- Checks for destructive operations (rm -rf, git reset --hard)
- Detects credential exposure
- Blocks network requests to unknown hosts

### PostToolUse Hook - File Modification Tracking
- Notification after Edit/Write operations
- Triggers formatting, linting, or audit logging

---

## 🎯 Recommended Workflows

### Secure Code Review
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
3. /python-architect - Implement
4. /generate-tests - Create test coverage
5. /security-engineer - Security review
6. /review-code - Final code review
```

### Database Optimization
```
1. /postgres-dba - Analyze query performance
2. Use MCP tools to run EXPLAIN ANALYZE
3. /backend-engineer - Implement caching strategy
```

---

## 📚 Best Practices

### Agent Design Principles
- **Single Responsibility:** Each agent has one clear expertise domain
- **Strict Tool Scoping:** Agents only have tools they need
- **Read-Only by Default:** Review agents use Read/Grep/Glob, not Edit/Write
- **Model Selection:** Sonnet for complex reasoning, Haiku for fast operations

### Security Hardening
- **Least Privilege:** Only grant permissions explicitly needed
- **Defense in Depth:** Multiple security layers (hooks + permissions + agents)
- **Secrets Management:** Never hardcode credentials
- **Input Validation:** Security agents enforce validation at all boundaries

---

## 🚀 Quick Commands

```bash
# Agent Management
/agents                    # List all agents
/agents refresh            # Reload agent definitions

# Skill Management
/skills                    # List all skills
/<skill-name>              # Invoke a skill

# MCP Management
/mcp                       # View MCP server status
claude mcp list            # CLI: List servers

# Configuration
/permissions               # View/modify permissions
/doctor                    # System diagnostics
```

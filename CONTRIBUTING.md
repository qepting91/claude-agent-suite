# Contributing to Claude Code Agent Suite

Thank you for your interest in contributing! This document provides guidelines for contributing agents, skills, and improvements.

## 🎯 Ways to Contribute

- **New Agents:** Add specialized agents for new languages or domains
- **Documentation:** Improve guides, add examples, fix typos
- **Bug Reports:** Report issues with existing agents
- **Security:** Report security vulnerabilities (see Security section)
- **Enhancements:** Improve existing agents or workflows

## 📝 Agent Contribution Guidelines

### Structure

All agents must follow this structure:

```markdown
---
name: agent-name
description: >-
  Clear, concise description of when to use this agent.
  Include specific technologies, patterns, or use cases.
tools: Read, Glob, Grep, Edit, Bash
model: sonnet
---

# Identity
Clear role definition...

# Core Principles
Key guidelines...

# Workflow
Step-by-step process...

# Best Practices
Specific recommendations...

# Tool Usage
How to use the allowed tools...
```

### Quality Checklist

- [ ] **Clear Description:** Router can accurately determine when to use this agent
- [ ] **Strict Tool Scoping:** Only includes necessary tools (principle of least privilege)
- [ ] **Specific Expertise:** Focused on one domain (not generic "helper" agent)
- [ ] **Actionable Instructions:** Clear, concrete steps (not vague guidance)
- [ ] **Security Conscious:** Includes security considerations if relevant
- [ ] **Tested:** Agent works as intended in real scenarios

### Agent Naming

- Use kebab-case: `python-architect`, `security-engineer`
- Be specific: ❌ `helper` ✅ `python-async-expert`
- Indicate role: `architect`, `engineer`, `specialist`, `expert`, `reviewer`

## 🔄 Pull Request Process

1. **Fork the Repository**
   ```bash
   git clone https://github.com/qepting91/claude-agent-suite.git
   cd claude-agent-suite
   git checkout -b feature/my-agent
   ```

2. **Add Your Agent**
   - Create agent file in `agents/`
   - Test thoroughly in Claude Code
   - Document any prerequisites

3. **Update Documentation**
   - Add agent to README.md agent list
   - Include usage examples
   - Note any required tools or dependencies

4. **Commit with Clear Messages**
   ```bash
   git add agents/my-agent.md
   git commit -m "Add [Language] specialist agent for [use case]"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/my-agent
   ```

## 🧪 Testing Your Agent

Before submitting, test your agent:

1. **Install Locally:**
   ```bash
   cp agents/my-agent.md ~/.claude/agents/
   ```

2. **Verify in Claude Code:**
   ```bash
   /agents
   ```

3. **Test Real Scenarios:**
   - Create sample files the agent would work with
   - Invoke the agent and verify behavior
   - Check that tool restrictions work

4. **Security Review:**
   - Ensure no hardcoded secrets
   - Verify tool permissions are minimal
   - Check for injection vulnerabilities in prompts

## 📚 Documentation Standards

### Agent Documentation

Each agent should be self-documenting:
- Identity section explains the role
- Clear sections for principles, workflow, best practices
- Examples of when to use vs. when NOT to use

### README Updates

When adding agents, update:
- Agent count in "What's Included"
- Agent list with brief description
- Any new prerequisites

### Code Examples

Use clear, copy-paste-ready examples:

```python
# ✅ Good: Clear, secure, idiomatic
async def fetch_user(user_id: int) -> User:
    async with db.transaction():
        return await db.users.get(user_id)
```

```python
# ❌ Bad: Vulnerable, anti-pattern
def get_user(id):
    return db.query(f"SELECT * FROM users WHERE id={id}")
```

## 🔒 Security Guidelines

### Secrets and Credentials

**NEVER commit:**
- API keys
- Passwords
- Connection strings with credentials
- Private keys
- `.env` files

**Use placeholders:**
```json
{
  "postgresql": "postgresql://USERNAME:PASSWORD@localhost:5432/DATABASE"
}
```

### Agent Security

- **Read-only agents** (reviewers, analyzers): Only `Read, Grep, Glob`
- **Code modification agents:** Add `Edit` only if necessary
- **System agents:** `Bash` requires strong justification
- **MCP agents:** Document exactly which MCP tools are exposed

### Security Vulnerabilities

If you discover a security vulnerability:
1. **DO NOT** create a public issue
2. Email: [Your security contact]
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if known)

## 💬 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the contribution, not the person
- Help newcomers learn

## 🏆 Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes for significant contributions
- README acknowledgments section

## 📞 Questions?

- **Issues:** https://github.com/qepting91/claude-agent-suite/issues
- **Discussions:** https://github.com/qepting91/claude-agent-suite/discussions
- **Agent Design:** Open a discussion before starting large agents

## 🎉 Thank You!

Every contribution, no matter how small, helps make this agent suite better for the community.

---

**Happy Contributing!**
- @qepting91

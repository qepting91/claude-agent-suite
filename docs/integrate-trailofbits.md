# Trail of Bits Security Skills - Quick Integration Guide

## Prerequisites
- Claude Code CLI installed and authenticated
- Python 3.11+ (for skills that require Python)
- Git (for version control operations)

---

## Step 1: Add the Trail of Bits Marketplace

Open Claude Code and run:
```
/plugin marketplace add trailofbits/skills
```

This adds the official Trail of Bits security skills repository to your marketplace.

---

## Step 2: Install Core Security Skills

### Essential Security Review Skills (Install First)

#### 1. Audit Context Building
**Purpose:** Ultra-granular line-by-line analysis for deep comprehension
**When to use:** Before starting any security audit
```
/plugin install trailofbits/skills/plugins/audit-context-building
```

#### 2. Differential Review
**Purpose:** Risk-based security review of code changes
**When to use:** Reviewing pull requests or commits
```
/plugin install trailofbits/skills/plugins/differential-review
```

#### 3. Variant Analysis
**Purpose:** Find similar vulnerabilities after identifying a pattern
**When to use:** After discovering a vulnerability
```
/plugin install trailofbits/skills/plugins/variant-analysis
```

#### 4. Fix Review
**Purpose:** Validates security patches actually address root causes
**When to use:** Reviewing security fixes
```
/plugin install trailofbits/skills/plugins/fix-review
```

### Static Analysis & Detection

#### 5. Static Analysis Integration
**Purpose:** CodeQL, Semgrep, SARIF parsing
**When to use:** Automated vulnerability scanning
```
/plugin install trailofbits/skills/plugins/static-analysis
```

#### 6. Semgrep Rule Creator
**Purpose:** Test-driven custom detection rule creation
**When to use:** Creating project-specific security patterns
```
/plugin install trailofbits/skills/plugins/semgrep-rule-creator
```

#### 7. Insecure Defaults
**Purpose:** Identifies dangerous fail-open configurations
**When to use:** Configuration security review
```
/plugin install trailofbits/skills/plugins/insecure-defaults
```

### Specialized Security

#### 8. Constant-Time Analysis
**Purpose:** Detects timing side-channel vulnerabilities
**When to use:** Reviewing cryptographic code
```
/plugin install trailofbits/skills/plugins/constant-time-analysis
```

#### 9. Property-Based Testing
**Purpose:** Systematic testing methodology
**When to use:** Developing comprehensive test suites
```
/plugin install trailofbits/skills/plugins/property-based-testing
```

### Development Best Practices

#### 10. Modern Python
**Purpose:** Secure Python development patterns
**When to use:** Python code review and development
```
/plugin install trailofbits/skills/plugins/modern-python
```

#### 11. Ask Questions If Underspecified
**Purpose:** Clarifies ambiguous requirements
**When to use:** Starting new features with unclear specs
```
/plugin install trailofbits/skills/plugins/ask-questions-if-underspecified
```

---

## Step 3: Verify Installation

Check installed plugins:
```
/plugin menu
```

You should see entries like:
- `trailofbits/skills/audit-context-building`
- `trailofbits/skills/differential-review`
- etc.

---

## Step 4: Using Trail of Bits Skills

### Invocation Methods

#### Method 1: Direct Invocation
```
/trailofbits:differential-review @file1.py @file2.py
```

#### Method 2: Let Claude Decide
Simply describe what you need:
```
"Review this security patch to ensure it fixes the root cause"
```

Claude will automatically invoke `/trailofbits:fix-review` if appropriate.

---

## Recommended Security Workflow

### For Pull Request Security Review:

```
Step 1: Build Context
/trailofbits:audit-context-building @src/

Step 2: Differential Analysis
/trailofbits:differential-review @changed-files

Step 3: Static Analysis
/trailofbits:static-analysis @src/

Step 4: Find Variants
/trailofbits:variant-analysis (if vulnerabilities found)

Step 5: Manual Review
/secure-code-reviewer (your custom agent)
```

### For New Feature Security Assessment:

```
Step 1: Clarify Requirements
/trailofbits:ask-questions-if-underspecified

Step 2: Threat Model
/security-engineer "Threat model this feature"

Step 3: Secure Design
/backend-engineer (or relevant architect)

Step 4: Implementation Review
/trailofbits:differential-review

Step 5: Cryptography Review (if applicable)
/trailofbits:constant-time-analysis
```

---

## Advanced Configuration

### Creating a Custom Security Skill Bundle

Create `.claude/skills/security-review-suite/SKILL.md`:

```markdown
---
name: security-review-suite
description: Comprehensive security review combining multiple Trail of Bits skills
context: fork
agent: Explore
---

You are conducting a comprehensive security review. Follow this workflow:

1. **Context Building**: Use audit-context-building to understand the codebase
2. **Static Analysis**: Run static-analysis to identify low-hanging fruit
3. **Differential Review**: Use differential-review for changed code
4. **Configuration Review**: Check insecure-defaults
5. **Variant Search**: If vulnerabilities found, use variant-analysis
6. **Final Report**: Summarize findings with severity ratings

Invoke each Trail of Bits skill sequentially and aggregate results.
```

Invoke with:
```
/security-review-suite @src/ @tests/
```

---

## Integration with Your Existing Agents

### Combining Agents and Skills

Your custom agents work alongside Trail of Bits skills:

**Example 1: Secure Code Review**
```
1. /secure-code-reviewer (your agent for initial scan)
2. /trailofbits:differential-review (deep analysis)
3. /trailofbits:variant-analysis (find similar issues)
```

**Example 2: Python Security Review**
```
1. /python-architect (code quality review)
2. /trailofbits:modern-python (security patterns)
3. /secure-code-reviewer (vulnerability scan)
```

**Example 3: Backend API Security**
```
1. /backend-engineer (API design review)
2. /security-engineer (threat modeling)
3. /trailofbits:static-analysis (automated scanning)
```

---

## Troubleshooting

### Skill Not Found
**Error:** `Skill 'trailofbits:...' not found`
**Fix:** Ensure marketplace is added: `/plugin marketplace add trailofbits/skills`

### Python Dependency Issues
**Error:** `ModuleNotFoundError: No module named 'X'`
**Fix:** Trail of Bits skills use PEP 723 inline metadata. Ensure `uv` is installed:
```bash
pip install uv
```

### Skill Not Auto-Invoking
**Issue:** Claude doesn't automatically use Trail of Bits skills
**Fix:** Be specific in your request:
- ❌ "Review this code"
- ✅ "Perform differential security review on this code change"

---

## Best Practices

### 1. Layer Your Security Reviews
- **Automated:** static-analysis
- **Pattern-Based:** semgrep-rule-creator
- **Manual:** secure-code-reviewer + differential-review
- **Exploratory:** variant-analysis

### 2. Document Findings
Create a standardized finding format:
```markdown
## [SEVERITY] Vulnerability Title
**Skill Used:** trailofbits:differential-review
**CWE:** CWE-89 (SQL Injection)
**File:** path/to/file.py:42
**Description:** ...
**Remediation:** ...
```

### 3. Continuous Learning
Trail of Bits skills include pedagogical anti-patterns. Pay attention to:
- "Rationalizations to Reject" sections
- False positive patterns
- Tool selection guidance (when to use grep vs Semgrep vs CodeQL)

### 4. Adapt to Your Stack
Not all skills apply to every project:
- `constant-time-analysis` → Cryptographic code only
- `building-secure-contracts` → Smart contract projects only
- `modern-python` → Python projects only

---

## Skill Reference Quick Guide

| Skill | Primary Use Case | Output |
|-------|------------------|--------|
| audit-context-building | Deep understanding | Architectural insights |
| differential-review | PR security review | Vulnerability report |
| variant-analysis | Similar bug detection | Pattern-based findings |
| fix-review | Patch validation | Root cause assessment |
| static-analysis | Automated scanning | Tool-aggregated results |
| semgrep-rule-creator | Custom detection | Semgrep YAML rules |
| insecure-defaults | Config review | Dangerous defaults list |
| constant-time-analysis | Crypto review | Timing vulnerabilities |
| property-based-testing | Test strategy | Test cases |
| modern-python | Python best practices | Secure code patterns |

---

## Updates & Maintenance

### Checking for Updates
Trail of Bits regularly updates their skills. Check for updates:
```bash
# In terminal (not in Claude Code)
cd ~/.claude/plugins/marketplaces/trailofbits-skills
git pull origin main
```

### Re-installing Skills
If a skill misbehaves:
```
/plugin uninstall trailofbits/skills/plugins/<skill-name>
/plugin install trailofbits/skills/plugins/<skill-name>
```

---

## Additional Resources

- **Trail of Bits Blog:** https://blog.trailofbits.com/
- **Skills Repository:** https://github.com/trailofbits/skills
- **Trophy Case:** Real vulnerabilities found using these skills (in repo README)
- **Security Handbook:** https://appsec.guide/

---

## Support

For issues with Trail of Bits skills:
- GitHub Issues: https://github.com/trailofbits/skills/issues
- Community: Trail of Bits blog and publications

For Claude Code integration issues:
- Claude Code Docs: https://code.claude.com/docs
- `/bug` command in Claude Code

---

**Quick Start Checklist:**
- [ ] Add marketplace: `/plugin marketplace add trailofbits/skills`
- [ ] Install audit-context-building
- [ ] Install differential-review
- [ ] Install static-analysis
- [ ] Test with: `/trailofbits:differential-review @src/`
- [ ] Review this guide's workflow examples

**Status:** Ready for Integration
**Last Updated:** 2026-02-02

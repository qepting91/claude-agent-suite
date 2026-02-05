---
sidebar_position: 4
---

# Security Skills Integration

Trail of Bits security skills integration guide for comprehensive vulnerability detection and secure development.

## Prerequisites

- Claude Code CLI installed and authenticated
- Python 3.11+ (for skills that require Python)
- Git (for version control operations)

---

## Step 1: Add the Trail of Bits Marketplace

```bash
/plugin marketplace add trailofbits/skills
```

---

## Step 2: Install Core Security Skills

### Essential Security Review Skills

| Skill | Purpose | Command |
|-------|---------|---------|
| **Audit Context Building** | Deep line-by-line analysis | `/plugin install trailofbits/skills/plugins/audit-context-building` |
| **Differential Review** | Risk-based PR review | `/plugin install trailofbits/skills/plugins/differential-review` |
| **Variant Analysis** | Find similar vulnerabilities | `/plugin install trailofbits/skills/plugins/variant-analysis` |
| **Fix Review** | Validate security patches | `/plugin install trailofbits/skills/plugins/fix-review` |

### Static Analysis & Detection

| Skill | Purpose | Command |
|-------|---------|---------|
| **Static Analysis** | CodeQL, Semgrep, SARIF | `/plugin install trailofbits/skills/plugins/static-analysis` |
| **Semgrep Rule Creator** | Custom detection rules | `/plugin install trailofbits/skills/plugins/semgrep-rule-creator` |
| **Insecure Defaults** | Dangerous fail-open configs | `/plugin install trailofbits/skills/plugins/insecure-defaults` |

### Specialized Security

| Skill | Purpose | Command |
|-------|---------|---------|
| **Constant-Time Analysis** | Timing side-channels | `/plugin install trailofbits/skills/plugins/constant-time-analysis` |
| **Property-Based Testing** | Systematic testing | `/plugin install trailofbits/skills/plugins/property-based-testing` |

---

## Step 3: Verify Installation

```bash
/plugin menu      # List installed plugins
/skills           # List available skills
```

---

## Using Trail of Bits Skills

### Direct Invocation
```bash
/trailofbits:differential-review @file1.py @file2.py
```

### Natural Language
Simply describe what you need:
> "Review this security patch to ensure it fixes the root cause"

Claude will automatically invoke the appropriate skill.

---

## Recommended Workflows

### Pull Request Security Review

```
Step 1: /trailofbits:audit-context-building @src/
Step 2: /trailofbits:differential-review @changed-files
Step 3: /trailofbits:static-analysis @src/
Step 4: /trailofbits:variant-analysis (if vulnerabilities found)
Step 5: /secure-code-reviewer (your custom agent)
```

### New Feature Security Assessment

```
Step 1: /trailofbits:ask-questions-if-underspecified
Step 2: /security-engineer "Threat model this feature"
Step 3: /backend-engineer (design review)
Step 4: /trailofbits:differential-review
Step 5: /trailofbits:constant-time-analysis (if crypto involved)
```

---

## Best Practices

### Layer Your Security Reviews
1. **Automated:** static-analysis
2. **Pattern-Based:** semgrep-rule-creator
3. **Manual:** secure-code-reviewer + differential-review
4. **Exploratory:** variant-analysis

### Document Findings
```markdown
## [SEVERITY] Vulnerability Title
**Skill Used:** trailofbits:differential-review
**CWE:** CWE-89 (SQL Injection)
**File:** path/to/file.py:42
**Description:** ...
**Remediation:** ...
```

---

## Skill Reference

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

---

## Resources

- **Trail of Bits Blog:** https://blog.trailofbits.com/
- **Skills Repository:** https://github.com/trailofbits/skills
- **Security Handbook:** https://appsec.guide/

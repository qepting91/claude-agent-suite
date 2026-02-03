# Repository Structure

This document describes the organization of the Claude Code Agent Suite repository, which uses a **template-based build system** to compile specialized AI agents.

## 🏗️ Build System Architecture

The project uses **Jinja2 templates** to compile agents:

```
Development Flow:
  src/agents/*.md.j2  →  scripts/build.py  →  dist/agents/*.md  →  install.sh/ps1  →  ~/.claude/agents/
  (edit these)           (compiler)           (generated)         (installer)         (user system)
```

**Key Concepts**:
- **Source of Truth**: `src/agents/*.md.j2` (Jinja2 templates)
- **Reusable Components**: `src/skills/` (shared modules)
- **Build Output**: `dist/agents/*.md` (generated, git-ignored)
- **Legacy Files**: `agents/*.md` (old static files, to be removed)

## 📁 Directory Layout

```
claude-agent-suite/
│
├── src/                              # SOURCE FILES (edit these)
│   ├── agents/                       # Jinja2 templates (*.md.j2)
│   │   ├── python-architect.md.j2
│   │   ├── go-expert.md.j2
│   │   └── ...  (16 templates total)
│   │
│   └── skills/                       # Reusable components
│       ├── common/
│       │   ├── cognitive_protocol.md
│       │   └── tool_usage_best_practices.md
│       └── security/
│           └── input_validation.md
│
├── dist/                             # COMPILED OUTPUT (generated)
│   └── agents/                       # Production-ready agents
│       ├── python-architect.md
│       ├── go-expert.md
│       └── ...  (16 compiled agents)
│
├── agents/                           # LEGACY (old static files)
│   ├── python-architect.md           # Pre-build-system versions
│   └── ...  (15 old files)           # Will be removed
│
├── scripts/                          # BUILD SYSTEM
│   └── build.py                      # Jinja2 compiler & validator
│
├── tests/                            # TEST SUITE
│   ├── __init__.py
│   ├── conftest.py                   # Pytest fixtures
│   ├── test_agent_builder.py        # Unit tests
│   ├── test_build_functions.py      # Function tests
│   ├── test_integration.py          # Integration tests
│   └── README.md                     # Testing documentation
│
├── config/                           # CONFIGURATION
│   ├── build_config.yml              # Build system settings
│   ├── dangerous_commands.json       # Bash pattern detection
│   └── settings.json                 # User settings template
│
├── docs/                             # DOCUMENTATION
│   ├── AGENT_TEAM_GUIDE.md           # Agent reference
│   └── integrate-trailofbits.md      # Security skills guide
│
├── .github/                          # CI/CD PIPELINE
│   └── workflows/
│       └── test.yml                  # GitHub Actions workflow
│
├── README.md                         # Main documentation
├── CLAUDE.md                         # Repository guidance for Claude Code
├── STRUCTURE.md                      # This file
├── CONTRIBUTING.md                   # Contribution guidelines
├── LICENSE                           # MIT License
├── .gitignore                        # Protects sensitive files, ignores dist/
│
├── install.sh                        # Linux/Mac installer
├── install.ps1                       # Windows installer
│
├── requirements.txt                  # Python dependencies
├── pytest.ini                        # Pytest configuration
└── Makefile                          # Build automation (Linux/Mac)
```

## 🎯 Directory Purposes

### Source Directories (Contributors Edit These)

#### `src/agents/` - Agent Templates
Jinja2 templates for each agent. Contributors edit these files.

**Format**:
```jinja2
---
name: agent-name
description: When to use this agent
tools: Read, Glob, Grep, Edit, Bash
model: sonnet
---

{% include "skills/common/cognitive_protocol.md" %}

# Identity
Agent-specific instructions...

{% include "skills/security/input_validation.md" %}
```

**16 Templates** (15 agents + 1 test agent):
- python-architect.md.j2
- go-expert.md.j2
- node-engineer.md.j2
- backend-engineer.md.j2
- frontend-architect.md.j2
- astro-expert.md.j2
- ux-ui-designer.md.j2
- streamlit-expert.md.j2
- powershell-automator.md.j2
- postgres-dba.md.j2
- mysql-expert.md.j2
- mongo-architect.md.j2
- security-engineer.md.j2
- secure-code-reviewer.md.j2
- prompt-engineer.md.j2
- test-agent.md.j2

#### `src/skills/` - Reusable Components
Markdown snippets included in templates via `{% include %}`. Enables DRY principles.

**Common Skills**:
- `common/cognitive_protocol.md`: Chain-of-thought reasoning framework
- `common/tool_usage_best_practices.md`: Tool usage guidelines

**Security Skills**:
- `security/input_validation.md`: Input validation patterns

**Usage Example**:
```jinja2
{% include "skills/common/cognitive_protocol.md" %}
```

### Build System Directories

#### `scripts/` - Build System
**build.py**: Python script that compiles templates to production agents.

**Features**:
- Discovers *.md.j2 templates in src/agents/
- Renders templates with Jinja2
- Validates frontmatter, token limits, bash syntax
- Detects dangerous command patterns
- Writes output to dist/agents/
- Reports statistics and errors

**Usage**:
```bash
python scripts/build.py              # Build all
python scripts/build.py --verbose    # Detailed output
python scripts/build.py --validate-only  # Check only
```

#### `dist/` - Compiled Output
Generated production agents. **Git-ignored** (not version controlled).

**Why git-ignored?**
- These are build artifacts, not source
- Can be regenerated from templates
- Reduces repository size
- Prevents merge conflicts on generated files

**Note**: Installation scripts copy from `dist/agents/` to user systems.

#### `agents/` - Legacy Files
Old static agent files from pre-build-system era. **These are obsolete** but kept temporarily for backwards compatibility.

**Will be removed** once migration is complete. Do not edit these files.

### Configuration Directories

#### `config/` - Build Configuration
**build_config.yml**: Build system settings
```yaml
build:
  source_dir: "src/agents"
  output_dir: "dist/agents"
  skills_dir: "src/skills"

validation:
  max_tokens: 2500
  required_frontmatter: [name, description, tools, model]
  allowed_models: [sonnet, haiku, opus]
```

**dangerous_commands.json**: Bash pattern detection
```json
{
  "categories": {
    "destructive_filesystem": {
      "severity": "critical",
      "patterns": ["rm -rf /", "rm -rf \\*"],
      "description": "Destructive filesystem operations"
    }
  }
}
```

**settings.json**: User settings template (hooks, permissions)
- Merged during installation (not overwritten)
- Contains PreToolUse/PostToolUse hooks
- Defines permission system

#### `docs/` - Documentation Files
Files copied to `~/.claude/` during installation:
- **AGENT_TEAM_GUIDE.md**: Complete agent reference
- **integrate-trailofbits.md**: Security skills guide

### Testing Directories

#### `tests/` - Test Suite
Pytest-based tests for build system.

**test_agent_builder.py**: Unit tests
- Initialization, configuration loading
- Token estimation
- Bash block extraction and validation
- Dangerous command detection
- Output validation
- Template discovery
- Compilation process

**test_build_functions.py**: Function-level tests
- Token estimation formula
- Regex patterns
- Template name extraction
- Validation rules

**test_integration.py**: Integration tests
- End-to-end build workflows
- Skill includes
- Variable substitution
- Build statistics
- CLI options

**conftest.py**: Pytest fixtures
- Temporary directories
- Valid/invalid templates
- Configuration files
- Dangerous commands config

**README.md**: Testing documentation
- How to run tests
- Coverage reports
- Test categories
- Adding new tests

#### `.github/` - CI/CD Pipeline
**workflows/test.yml**: GitHub Actions workflow

**Jobs**:
1. **test**: Runs pytest on 3 OS × 4 Python versions = 12 combinations
2. **lint**: Code formatting (black, isort, flake8, mypy)
3. **build-test**: Validates build system produces output

**Coverage**: Uploads to Codecov for tracking

### Documentation Files

#### Root Files
- **README.md**: Main documentation, installation guide
- **CLAUDE.md**: Repository guidance for Claude Code AI
- **STRUCTURE.md**: This file - repository organization
- **CONTRIBUTING.md**: Contribution guidelines
- **LICENSE**: MIT License

#### Installation Scripts
- **install.sh**: Linux/Mac automated installer
- **install.ps1**: Windows PowerShell installer

Both scripts:
1. Check prerequisites
2. Backup existing configuration
3. **Run build system** to generate agents
4. Copy `dist/agents/*.md` to `~/.claude/agents/`
5. Copy docs to `~/.claude/`
6. Merge settings.json
7. Verify installation

## 🔄 Workflows

### User Installation Flow

```
1. User clones repository
   git clone https://github.com/qepting91/claude-agent-suite.git
   ↓
2. User runs installer
   ./install.sh  (or install.ps1 on Windows)
   ↓
3. Installer runs build system
   python scripts/build.py → generates dist/agents/*.md
   ↓
4. Installer copies to user system
   cp dist/agents/*.md ~/.claude/agents/
   ↓
5. User opens Claude Code
   /agents → sees all 15 agents
```

### Contributor Development Flow

```
1. Fork/clone repository
   ↓
2. Edit template
   vim src/agents/python-architect.md.j2
   ↓
3. Build locally
   python scripts/build.py --verbose
   ↓
4. Verify output
   cat dist/agents/python-architect.md
   ↓
5. Test locally
   cp dist/agents/python-architect.md ~/.claude/agents/
   /python-architect "test task"
   ↓
6. Run automated tests
   pytest -v
   ↓
7. Commit source only
   git add src/agents/python-architect.md.j2
   git commit -m "Update python-architect cognitive protocol"
   ↓
8. Push and create PR
   git push origin feature-branch
   gh pr create
   ↓
9. CI/CD validates
   - Tests pass on 12 platform/Python combinations
   - Linters pass
   - Build succeeds
   ↓
10. Maintainer reviews and merges
```

### Update Flow

```
1. User pulls updates
   git pull origin main
   ↓
2. User re-runs installer
   ./install.sh
   ↓
3. Installer creates new backup
   ~/.claude.backup.TIMESTAMP
   ↓
4. Installer rebuilds from updated templates
   python scripts/build.py
   ↓
5. Updated agents copied to user system
   dist/agents/*.md → ~/.claude/agents/
   ↓
6. Settings preserved (merged, not overwritten)
```

## 📦 What Gets Installed

After running the installation script:

```
~/.claude/
├── agents/                          # 15 compiled agents
│   ├── python-architect.md          # From dist/agents/ (compiled from src/agents/python-architect.md.j2)
│   ├── go-expert.md
│   └── ...  (13 more agents)
│
├── AGENT_TEAM_GUIDE.md              # From docs/
├── integrate-trailofbits.md         # From docs/
│
└── settings.json                     # Merged with existing (preserves user changes)
```

**Note**: Users never see `src/` directory. They receive compiled agents from `dist/`.

## 🔒 Security & Git Exclusions

### .gitignore Rules

**Never Committed** (git-ignored):
```
# Build outputs
dist/                    # Generated agents

# Sensitive data
.credentials.json
*.env
*.pem
*.key
secrets/

# Test outputs
.coverage
htmlcov/
.pytest_cache/

# OS files
.DS_Store
Thumbs.db
```

**Always Committed** (version controlled):
```
# Source templates
src/agents/*.md.j2
src/skills/**/*.md

# Build system
scripts/build.py
config/build_config.yml

# Tests
tests/**/*.py

# Documentation
README.md
CLAUDE.md
STRUCTURE.md
```

### Why This Matters

**Security**: Prevents accidental commit of credentials or secrets
**Cleanliness**: Generated files don't clutter git history
**Simplicity**: Only source files are tracked, build artifacts are ephemeral

## 🎯 Design Philosophy

**Separation of Concerns**:
- `src/` = source of truth (edit these)
- `dist/` = build artifacts (generated)
- `~/.claude/` = user installation (runtime)

**DRY (Don't Repeat Yourself)**:
- Shared patterns in `src/skills/`
- Included via Jinja2 `{% include %}`
- Changes propagate to all agents

**Validation First**:
- Token limits enforced
- Bash syntax checked
- Dangerous commands detected
- Frontmatter validated

**Testing Mandatory**:
- Unit tests for each component
- Integration tests for workflows
- CI/CD on every commit
- Coverage tracking

**User-Friendly Distribution**:
- Automated installers
- Safe backups
- Merge (not overwrite) settings
- Cross-platform support

## 📊 Repository Stats

- **Source Templates**: 16 (15 agents + 1 test agent)
- **Reusable Skills**: 3 modules
- **Compiled Agents**: 16 (generated)
- **Test Cases**: 15+ pytest tests
- **Test Coverage**: >90%
- **CI/CD Platforms**: 3 (Ubuntu, Windows, macOS)
- **Python Versions Tested**: 4 (3.10, 3.11, 3.12, 3.13)
- **Documentation Files**: 5 (README, CLAUDE, STRUCTURE, CONTRIBUTING, AGENT_TEAM_GUIDE)

## 🛠️ Build System Benefits

**For Users**:
- High-quality, validated agents
- Consistent patterns across agents
- Tested on multiple platforms
- Professional-grade distribution

**For Contributors**:
- DRY principles via includes
- Automated validation catches errors
- Test suite ensures quality
- CI/CD provides fast feedback
- Clear separation of source and output

**For Maintainers**:
- Easy to update shared patterns
- Validation prevents regressions
- Tests document expected behavior
- CI/CD reduces manual review burden

---

**For more information, see:**
- Installation & Usage: [README.md](README.md)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)
- Agent Reference: [docs/AGENT_TEAM_GUIDE.md](docs/AGENT_TEAM_GUIDE.md)
- Repository Guidance: [CLAUDE.md](CLAUDE.md)
- Testing: [tests/README.md](tests/README.md)

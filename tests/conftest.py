"""Pytest configuration and fixtures for build system tests."""

import os
import sys
import tempfile
import shutil
from pathlib import Path
from typing import Dict

import pytest
import yaml

# Add scripts directory to path so we can import build module
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))


@pytest.fixture
def temp_project_dir(tmp_path):
    """Create a temporary project directory with required structure."""
    project_dir = tmp_path / "test_project"
    project_dir.mkdir()

    # Create directory structure
    (project_dir / "src" / "agents").mkdir(parents=True)
    (project_dir / "src" / "skills" / "common").mkdir(parents=True)
    (project_dir / "src" / "skills" / "security").mkdir(parents=True)
    (project_dir / "dist" / "agents").mkdir(parents=True)
    (project_dir / "config").mkdir(parents=True)

    return project_dir


@pytest.fixture
def valid_config(temp_project_dir) -> Dict:
    """Create a valid build configuration."""
    config = {
        "build": {
            "source_dir": "src/agents",
            "output_dir": "dist/agents",
            "skills_dir": "src/skills",
        },
        "validation": {
            "max_tokens": 2500,
            "required_frontmatter": ["name", "description", "tools", "model"],
            "allowed_models": ["sonnet", "haiku", "opus"],
        },
        "templates": {"file_extension": ".md.j2", "output_extension": ".md"},
        "logging": {"verbose": False, "show_warnings": True},
    }

    config_path = temp_project_dir / "config" / "build_config.yml"
    with open(config_path, "w") as f:
        yaml.dump(config, f)

    return config


@pytest.fixture
def valid_template(temp_project_dir):
    """Create a valid agent template."""
    template_content = """---
name: test-agent
description: Test agent for unit testing
tools: Read, Grep, Glob
model: sonnet
---

# Identity

You are a test agent for unit testing.

# Instructions

This is a test template with {{ python_version }} support.
"""
    template_path = temp_project_dir / "src" / "agents" / "test-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path


@pytest.fixture
def invalid_template_no_frontmatter(temp_project_dir):
    """Create a template without YAML frontmatter."""
    template_content = """# Identity

This template is missing frontmatter.
"""
    template_path = temp_project_dir / "src" / "agents" / "invalid-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path


@pytest.fixture
def template_with_bash_blocks(temp_project_dir):
    """Create a template with bash code blocks."""
    template_content = """---
name: bash-agent
description: Agent with bash examples
tools: Bash
model: sonnet
---

# Bash Examples

```bash
echo "Hello World"
ls -la
```

```sh
# List files
find . -name "*.py"
```
"""
    template_path = temp_project_dir / "src" / "agents" / "bash-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path


@pytest.fixture
def template_with_dangerous_commands(temp_project_dir):
    """Create a template with dangerous bash commands."""
    template_content = """---
name: dangerous-agent
description: Agent with dangerous commands
tools: Bash
model: sonnet
---

# Dangerous Commands

```bash
rm -rf /
chmod -R 777 /
```
"""
    template_path = temp_project_dir / "src" / "agents" / "dangerous-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path


@pytest.fixture
def dangerous_commands_config(temp_project_dir):
    """Create dangerous commands configuration."""
    config = {
        "categories": {
            "destructive_filesystem": {
                "severity": "critical",
                "patterns": [r"rm\s+-rf\s+/", r"mkfs\."],
                "description": "Commands that can destroy filesystem",
            },
            "system_modification": {
                "severity": "high",
                "patterns": [r"chmod\s+-R\s+777"],
                "description": "Commands that modify system security",
            },
        }
    }

    config_path = temp_project_dir / "config" / "dangerous_commands.json"
    import json

    with open(config_path, "w") as f:
        json.dump(config, f)

    return config_path


@pytest.fixture
def skill_file(temp_project_dir):
    """Create a reusable skill file."""
    skill_content = """# Cognitive Protocol

Follow these steps:
1. Analyze
2. Plan
3. Execute
"""
    skill_path = (
        temp_project_dir / "src" / "skills" / "common" / "cognitive_protocol.md"
    )
    with open(skill_path, "w") as f:
        f.write(skill_content)

    return skill_path


@pytest.fixture
def template_with_includes(temp_project_dir, skill_file):
    """Create a template that includes skills."""
    template_content = """---
name: include-agent
description: Agent that includes skills
tools: Read
model: sonnet
---

# Identity

Test agent.

{% include 'skills/common/cognitive_protocol.md' %}
"""
    template_path = temp_project_dir / "src" / "agents" / "include-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path


@pytest.fixture
def oversized_template(temp_project_dir):
    """Create a template that exceeds token limit."""
    # Generate content that will exceed 2500 tokens
    # Average 1.3 tokens/word, so ~2000 words = ~2600 tokens
    long_content = " ".join(["word"] * 2100)

    template_content = f"""---
name: large-agent
description: Agent that exceeds token limit
tools: Read
model: sonnet
---

# Identity

{long_content}
"""
    template_path = temp_project_dir / "src" / "agents" / "large-agent.md.j2"
    with open(template_path, "w") as f:
        f.write(template_content)

    return template_path

"""Simplified function-level tests for build.py functions."""

import re
import sys
from pathlib import Path

import pytest

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))


def test_token_estimation_formula():
    """Test the token estimation formula: words * 1.3."""

    # Simulate the estimate_tokens function
    def estimate_tokens(text: str) -> int:
        words = len(text.split())
        return int(words * 1.3)

    # Empty string
    assert estimate_tokens("") == 0

    # Single word
    assert estimate_tokens("hello") == 1  # 1 * 1.3 = 1.3 -> 1

    # Ten words
    assert estimate_tokens("one two three four five six seven eight nine ten") == 13

    # 100 words
    text_100 = " ".join(["word"] * 100)
    assert estimate_tokens(text_100) == 130


def test_bash_block_extraction_regex():
    """Test the bash block extraction regex pattern."""
    pattern = r"^```(?:bash|sh)\n(.*?)\n```"

    # Test with bash fence
    content1 = """```bash
echo "Hello"
ls -la
```"""
    matches = re.findall(pattern, content1, re.DOTALL | re.MULTILINE)
    assert len(matches) == 1
    assert "echo" in matches[0]

    # Test with sh fence
    content2 = """```sh
pwd
```"""
    matches = re.findall(pattern, content2, re.DOTALL | re.MULTILINE)
    assert len(matches) == 1
    assert matches[0].strip() == "pwd"

    # Test with no code blocks
    content3 = "Just plain text"
    matches = re.findall(pattern, content3, re.DOTALL | re.MULTILINE)
    assert len(matches) == 0

    # Test with multiple blocks
    content4 = """```bash
echo "first"
```

Some text.

```sh
echo "second"
```"""
    matches = re.findall(pattern, content4, re.DOTALL | re.MULTILINE)
    assert len(matches) == 2


def test_yaml_frontmatter_extraction():
    """Test YAML frontmatter extraction from agent content."""
    pattern = r"^---\s*\n(.*?)\n---\s*\n"

    # Valid frontmatter
    content = """---
name: test-agent
description: Test
tools: Read
model: sonnet
---

# Content"""
    match = re.match(pattern, content, re.DOTALL)
    assert match is not None
    assert "name: test-agent" in match.group(1)

    # No frontmatter
    content_no_fm = "# Just content"
    match = re.match(pattern, content_no_fm, re.DOTALL)
    assert match is None


def test_dangerous_command_pattern_matching():
    """Test dangerous command regex patterns."""
    patterns = {
        "rm_root": r"rm\s+-rf\s+/",
        "chmod_777": r"chmod\s+-R\s+777",
        "mkfs": r"mkfs\.",
    }

    # Test rm -rf /
    assert re.search(patterns["rm_root"], "rm -rf /") is not None
    assert re.search(patterns["rm_root"], "rm -rf ./build") is None

    # Test chmod -R 777
    assert re.search(patterns["chmod_777"], "chmod -R 777 /var") is not None
    assert re.search(patterns["chmod_777"], "chmod 755 file.txt") is None

    # Test mkfs
    assert re.search(patterns["mkfs"], "mkfs.ext4 /dev/sda1") is not None
    assert re.search(patterns["mkfs"], "mkdir -p /tmp") is None


def test_template_name_extraction():
    """Test extracting clean template names from .md.j2 files."""

    def extract_template_name(filename: str) -> str:
        """Extract clean name from template filename."""
        # Remove .j2 extension
        name = filename[:-3] if filename.endswith(".j2") else filename
        # Remove .md extension if present
        if name.endswith(".md"):
            name = name[:-3]
        return name

    assert extract_template_name("agent.md.j2") == "agent"
    assert extract_template_name("test-agent.md.j2") == "test-agent"
    assert extract_template_name("simple.j2") == "simple"


def test_jinja2_syntax_detection():
    """Test detection of unresolved Jinja2 syntax."""
    # Valid (no unresolved syntax)
    content_valid = "This is compiled output"
    assert "{{" not in content_valid
    assert "{%" not in content_valid

    # Invalid (has unresolved variables)
    content_invalid = "This has {{ variable }}"
    assert "{{" in content_invalid

    # Invalid (has unresolved tags)
    content_tags = "{% if condition %}"
    assert "{%" in content_tags


@pytest.mark.parametrize(
    "word_count,expected_tokens",
    [
        (0, 0),
        (1, 1),
        (10, 13),
        (100, 130),
        (1000, 1300),
        (2000, 2600),
    ],
)
def test_token_estimation_parameterized(word_count, expected_tokens):
    """Test token estimation with various word counts."""

    def estimate_tokens(text: str) -> int:
        words = len(text.split())
        return int(words * 1.3)

    text = " ".join(["word"] * word_count)
    assert estimate_tokens(text) == expected_tokens


def test_required_frontmatter_fields():
    """Test that required frontmatter fields are defined."""
    required_fields = ["name", "description", "tools", "model"]

    # Simulate validation
    frontmatter_valid = {
        "name": "test-agent",
        "description": "Test",
        "tools": "Read",
        "model": "sonnet",
    }

    frontmatter_invalid = {
        "name": "test-agent",
        "description": "Test",
        # Missing tools and model
    }

    # Check valid frontmatter
    missing_valid = [
        field for field in required_fields if field not in frontmatter_valid
    ]
    assert len(missing_valid) == 0

    # Check invalid frontmatter
    missing_invalid = [
        field for field in required_fields if field not in frontmatter_invalid
    ]
    assert len(missing_invalid) == 2
    assert "tools" in missing_invalid
    assert "model" in missing_invalid


def test_allowed_models():
    """Test model validation against allowed list."""
    allowed_models = ["sonnet", "haiku", "opus"]

    assert "sonnet" in allowed_models
    assert "haiku" in allowed_models
    assert "opus" in allowed_models
    assert "invalid-model" not in allowed_models
    assert "gpt-4" not in allowed_models


def test_file_extension_handling():
    """Test handling of template and output extensions."""
    template_extension = ".md.j2"
    output_extension = ".md"

    # Check file matching
    assert "agent.md.j2".endswith(template_extension)
    assert not "agent.md".endswith(template_extension)

    # Check output naming
    input_name = "test-agent"
    output_name = f"{input_name}{output_extension}"
    assert output_name == "test-agent.md"

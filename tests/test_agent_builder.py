"""Unit tests for AgentBuilder class."""

import os
import sys
import subprocess
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest
import yaml

# Import the module under test
from build import AgentBuilder


class TestAgentBuilderInit:
    """Test AgentBuilder initialization."""

    def test_init_with_valid_config(self, temp_project_dir, valid_config):
        """Test initialization with valid configuration."""
        builder = AgentBuilder(
            config_path="config/build_config.yml", root_dir=temp_project_dir
        )

        assert builder.root_dir == temp_project_dir
        assert builder.config == valid_config
        assert builder.stats == {"total": 0, "success": 0, "failed": 0, "warnings": 0}

    def test_init_creates_output_directory(self, temp_project_dir, valid_config):
        """Test that initialization creates output directory if it doesn't exist."""
        # Remove output directory
        output_dir = temp_project_dir / "dist" / "agents"
        if output_dir.exists():
            import shutil

            shutil.rmtree(output_dir)

        builder = AgentBuilder(
            config_path="config/build_config.yml", root_dir=temp_project_dir
        )

        assert output_dir.exists()

    def test_init_with_missing_config_exits(self, temp_project_dir):
        """Test that missing config file causes sys.exit(1)."""
        with pytest.raises(SystemExit) as exc_info:
            AgentBuilder(config_path="nonexistent.yml", root_dir=temp_project_dir)

        assert exc_info.value.code == 1

    def test_init_with_invalid_yaml_exits(self, temp_project_dir):
        """Test that invalid YAML causes sys.exit(1)."""
        # Create invalid YAML file
        config_path = temp_project_dir / "config" / "invalid.yml"
        with open(config_path, "w") as f:
            f.write("invalid: yaml: content: [")

        with pytest.raises(SystemExit) as exc_info:
            AgentBuilder(config_path="config/invalid.yml", root_dir=temp_project_dir)

        assert exc_info.value.code == 1


class TestEstimateTokens:
    """Test token estimation."""

    def test_estimate_tokens_with_empty_string(self, temp_project_dir, valid_config):
        """Test token estimation with empty string."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        tokens = builder.estimate_tokens("")

        assert tokens == 0

    def test_estimate_tokens_with_simple_text(self, temp_project_dir, valid_config):
        """Test token estimation with simple text."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        # 10 words * 1.3 = 13 tokens
        tokens = builder.estimate_tokens(
            "one two three four five six seven eight nine ten"
        )

        assert tokens == 13

    def test_estimate_tokens_formula(self, temp_project_dir, valid_config):
        """Test that token estimation uses 1.3 multiplier."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        text = " ".join(["word"] * 100)  # 100 words
        tokens = builder.estimate_tokens(text)

        assert tokens == 130  # 100 * 1.3


class TestExtractBashBlocks:
    """Test bash code block extraction."""

    def test_extract_bash_blocks_with_no_blocks(self, temp_project_dir, valid_config):
        """Test extraction when no bash blocks present."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        blocks = builder.extract_bash_blocks("This is plain text.")

        assert blocks == []

    def test_extract_bash_blocks_with_bash_fence(self, temp_project_dir, valid_config):
        """Test extraction of bash code blocks."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        content = """```bash
echo "Hello"
ls -la
```"""
        blocks = builder.extract_bash_blocks(content)

        assert len(blocks) == 1
        assert "echo" in blocks[0]
        assert "ls -la" in blocks[0]

    def test_extract_bash_blocks_with_sh_fence(self, temp_project_dir, valid_config):
        """Test extraction of sh code blocks."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        content = """```sh
pwd
```"""
        blocks = builder.extract_bash_blocks(content)

        assert len(blocks) == 1
        assert blocks[0] == "pwd"

    def test_extract_bash_blocks_filters_empty(self, temp_project_dir, valid_config):
        """Test that empty blocks are filtered out."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        content = """```bash

```"""
        blocks = builder.extract_bash_blocks(content)

        assert blocks == []

    def test_extract_bash_blocks_multiple_blocks(self, temp_project_dir, valid_config):
        """Test extraction of multiple bash blocks."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        content = """```bash
echo "first"
```

Some text.

```sh
echo "second"
```"""
        blocks = builder.extract_bash_blocks(content)

        assert len(blocks) == 2
        assert "first" in blocks[0]
        assert "second" in blocks[1]


class TestValidateBashSyntax:
    """Test bash syntax validation."""

    def test_validate_bash_syntax_with_valid_code(self, temp_project_dir, valid_config):
        """Test validation of valid bash code."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(returncode=0, stderr="")

            is_valid, error_msg = builder.validate_bash_syntax("echo 'test'")

            assert is_valid is True
            assert error_msg == ""

    def test_validate_bash_syntax_with_invalid_code(
        self, temp_project_dir, valid_config
    ):
        """Test validation of invalid bash code."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=1, stderr="syntax error near unexpected token"
            )

            is_valid, error_msg = builder.validate_bash_syntax("if [ missing bracket")

            assert is_valid is False
            assert "syntax error" in error_msg

    def test_validate_bash_syntax_when_bash_not_found(
        self, temp_project_dir, valid_config
    ):
        """Test validation when bash is not available."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        with patch("subprocess.run", side_effect=FileNotFoundError):
            is_valid, error_msg = builder.validate_bash_syntax("echo 'test'")

            # Should skip validation gracefully
            assert is_valid is True
            assert error_msg == ""

    def test_validate_bash_syntax_on_timeout(self, temp_project_dir, valid_config):
        """Test validation when bash times out."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        with patch("subprocess.run", side_effect=subprocess.TimeoutExpired("bash", 5)):
            is_valid, error_msg = builder.validate_bash_syntax(
                "while true; do echo 'loop'; done"
            )

            # Should skip validation on timeout
            assert is_valid is True
            assert error_msg == ""

    def test_validate_bash_syntax_with_empty_stderr(
        self, temp_project_dir, valid_config
    ):
        """Test validation when bash returns non-zero with empty stderr (WSL case)."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(returncode=1, stderr="")

            is_valid, error_msg = builder.validate_bash_syntax("echo 'test'")

            # Should skip validation when stderr is empty
            assert is_valid is True
            assert error_msg == ""


class TestCheckDangerousCommands:
    """Test dangerous command detection."""

    def test_check_dangerous_commands_with_no_config(
        self, temp_project_dir, valid_config
    ):
        """Test when dangerous commands config doesn't exist."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        warnings = builder.check_dangerous_commands("rm -rf /")

        assert warnings == []

    def test_check_dangerous_commands_detects_destructive(
        self, temp_project_dir, valid_config, dangerous_commands_config
    ):
        """Test detection of destructive filesystem commands."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        warnings = builder.check_dangerous_commands("rm -rf /")

        assert len(warnings) > 0
        assert warnings[0]["severity"] == "critical"
        assert "destructive_filesystem" in warnings[0]["category"]

    def test_check_dangerous_commands_detects_chmod(
        self, temp_project_dir, valid_config, dangerous_commands_config
    ):
        """Test detection of chmod 777 commands."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        warnings = builder.check_dangerous_commands("chmod -R 777 /var/www")

        assert len(warnings) > 0
        assert warnings[0]["severity"] == "high"
        assert "system_modification" in warnings[0]["category"]

    def test_check_dangerous_commands_safe_command(
        self, temp_project_dir, valid_config, dangerous_commands_config
    ):
        """Test that safe commands produce no warnings."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        warnings = builder.check_dangerous_commands("echo 'Hello World'")

        assert warnings == []


class TestValidateOutput:
    """Test output validation."""

    def test_validate_output_with_valid_content(self, temp_project_dir, valid_config):
        """Test validation of valid agent content."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        content = """---
name: test-agent
description: Test agent
tools: Read, Grep
model: sonnet
---

# Identity

You are a test agent.
"""
        is_valid, errors = builder.validate_output(content, "test-agent.md")

        assert is_valid is True
        assert errors == []

    def test_validate_output_missing_frontmatter(self, temp_project_dir, valid_config):
        """Test validation fails when frontmatter is missing."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        content = "# Identity\n\nNo frontmatter."
        is_valid, errors = builder.validate_output(content, "test.md")

        assert is_valid is False
        assert any("frontmatter" in err.lower() for err in errors)

    def test_validate_output_missing_required_field(
        self, temp_project_dir, valid_config
    ):
        """Test validation fails when required field is missing."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        content = """---
name: test-agent
description: Test
---

Content
"""
        is_valid, errors = builder.validate_output(content, "test.md")

        assert is_valid is False
        assert any("tools" in err for err in errors)
        assert any("model" in err for err in errors)

    def test_validate_output_invalid_model(self, temp_project_dir, valid_config):
        """Test validation fails with invalid model."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        content = """---
name: test-agent
description: Test
tools: Read
model: invalid-model
---

Content
"""
        is_valid, errors = builder.validate_output(content, "test.md")

        assert is_valid is False
        assert any("invalid model" in err.lower() for err in errors)

    def test_validate_output_unresolved_jinja(self, temp_project_dir, valid_config):
        """Test validation fails with unresolved Jinja2 syntax."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        content = """---
name: test-agent
description: Test
tools: Read
model: sonnet
---

{{ unresolved_variable }}
"""
        is_valid, errors = builder.validate_output(content, "test.md")

        assert is_valid is False
        assert any("jinja2" in err.lower() for err in errors)

    def test_validate_output_exceeds_token_limit(self, temp_project_dir, valid_config):
        """Test validation fails when token limit is exceeded."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        # Create content exceeding 2500 tokens (~2000 words)
        long_content = " ".join(["word"] * 2100)
        content = f"""---
name: test-agent
description: Test
tools: Read
model: sonnet
---

{long_content}
"""
        is_valid, errors = builder.validate_output(content, "test.md")

        assert is_valid is False
        assert any("token" in err.lower() for err in errors)


class TestDiscoverTemplates:
    """Test template discovery."""

    def test_discover_templates_finds_templates(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that discover_templates finds .md.j2 files."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        templates = builder.discover_templates()

        assert len(templates) > 0
        assert any(t.name == "test-agent.md.j2" for t in templates)

    def test_discover_templates_empty_directory(self, temp_project_dir, valid_config):
        """Test discover_templates with no templates."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        templates = builder.discover_templates()

        assert templates == []


class TestCompileTemplate:
    """Test template compilation."""

    def test_compile_template_success(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test successful template compilation."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        success, output_path = builder.compile_template(valid_template, verbose=False)

        assert success is True
        assert output_path is not None
        assert Path(output_path).exists()

    def test_compile_template_creates_output_file(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that compilation creates output file."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        success, output_path = builder.compile_template(valid_template)

        output_file = Path(output_path)
        assert output_file.exists()

        # Verify content
        with open(output_file, "r") as f:
            content = f.read()
            assert "test-agent" in content
            assert "{{ python_version }}" not in content  # Variables should be resolved

    def test_compile_template_validation_failure(
        self, temp_project_dir, valid_config, invalid_template_no_frontmatter
    ):
        """Test compilation fails on validation error."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        success, output_path = builder.compile_template(invalid_template_no_frontmatter)

        assert success is False
        assert output_path is None


class TestBuildAll:
    """Test build_all method."""

    def test_build_all_success(self, temp_project_dir, valid_config, valid_template):
        """Test building all templates successfully."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        exit_code = builder.build_all(verbose=False, validate_only=False)

        assert exit_code == 0
        assert builder.stats["success"] > 0
        assert builder.stats["failed"] == 0

    def test_build_all_with_failures(
        self, temp_project_dir, valid_config, invalid_template_no_frontmatter
    ):
        """Test build_all returns error code on failures."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        exit_code = builder.build_all(verbose=False, validate_only=False)

        assert exit_code == 1
        assert builder.stats["failed"] > 0

    def test_build_all_validate_only_mode(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test build_all in validate-only mode doesn't write files."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        # Clear output directory
        output_dir = temp_project_dir / "dist" / "agents"
        for f in output_dir.glob("*.md"):
            f.unlink()

        exit_code = builder.build_all(verbose=False, validate_only=True)

        # No files should be written
        output_files = list(output_dir.glob("*.md"))
        assert len(output_files) == 0

    def test_build_all_no_templates(self, temp_project_dir, valid_config):
        """Test build_all with no templates returns success."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        exit_code = builder.build_all()

        assert exit_code == 0

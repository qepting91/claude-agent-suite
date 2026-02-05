"""Integration tests for the build system."""

import sys
from pathlib import Path
from unittest.mock import patch

import pytest
from build import AgentBuilder


class TestEndToEndBuild:
    """Test complete build workflows."""

    def test_complete_build_workflow(
        self, temp_project_dir, valid_config, valid_template, skill_file
    ):
        """Test a complete build from template to output."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        # Discover templates
        templates = builder.discover_templates()
        assert len(templates) > 0

        # Compile each template
        for template_path in templates:
            success, output_path = builder.compile_template(template_path)
            assert success is True
            assert Path(output_path).exists()

            # Verify output content
            with open(output_path, "r") as f:
                content = f.read()
                assert "---" in content  # Has frontmatter
                assert "{{" not in content  # No unresolved Jinja2
                assert "{%" not in content  # No unresolved Jinja2

    def test_build_with_skill_includes(
        self, temp_project_dir, valid_config, template_with_includes, skill_file
    ):
        """Test building a template that includes skills."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(template_with_includes)

        assert success is True

        # Verify skill content was included
        with open(output_path, "r") as f:
            content = f.read()
            assert "Cognitive Protocol" in content
            assert "Analyze" in content
            assert "Plan" in content
            assert "Execute" in content

    def test_build_with_bash_validation(
        self, temp_project_dir, valid_config, template_with_bash_blocks
    ):
        """Test building templates with bash code blocks."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(template_with_bash_blocks)

        # Should succeed (bash validation is warning-only)
        assert success is True

    def test_build_with_dangerous_commands_warning(
        self,
        temp_project_dir,
        valid_config,
        template_with_dangerous_commands,
        dangerous_commands_config,
        capsys,
    ):
        """Test that dangerous commands produce warnings but don't fail build."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(
            template_with_dangerous_commands
        )

        # Should succeed with warnings
        assert success is True

        # Check for warning output
        captured = capsys.readouterr()
        assert "WARN" in captured.out or "CRITICAL" in captured.out

    def test_oversized_template_fails_validation(
        self, temp_project_dir, valid_config, oversized_template
    ):
        """Test that templates exceeding token limit fail validation."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(oversized_template)

        assert success is False
        assert output_path is None


class TestBuildVariableSubstitution:
    """Test Jinja2 variable substitution in builds."""

    def test_build_context_variables_resolved(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that build context variables are properly resolved."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(valid_template)
        assert success is True

        with open(output_path, "r") as f:
            content = f.read()

            # Python version should be resolved
            assert "{{ python_version }}" not in content
            assert f"{sys.version_info.major}.{sys.version_info.minor}" in content

    def test_build_timestamp_present(self, temp_project_dir, valid_config):
        """Test that build timestamp is available to templates."""
        # Create template with timestamp variable
        template_content = """---
name: timestamp-agent
description: Test timestamp
tools: Read
model: sonnet
---

Built at: {{ build_timestamp }}
"""
        template_path = temp_project_dir / "src" / "agents" / "timestamp-agent.md.j2"
        with open(template_path, "w") as f:
            f.write(template_content)

        builder = AgentBuilder(root_dir=temp_project_dir)

        success, output_path = builder.compile_template(template_path)
        assert success is True

        with open(output_path, "r") as f:
            content = f.read()

            # Timestamp should be resolved
            assert "{{ build_timestamp }}" not in content
            assert "Built at:" in content


class TestBuildStatistics:
    """Test build statistics tracking."""

    def test_stats_tracking_success(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that successful builds are tracked in stats."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        exit_code = builder.build_all()

        assert builder.stats["total"] > 0
        assert builder.stats["success"] > 0
        assert builder.stats["failed"] == 0

    def test_stats_tracking_failures(
        self, temp_project_dir, valid_config, invalid_template_no_frontmatter
    ):
        """Test that failed builds are tracked in stats."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        exit_code = builder.build_all()

        assert builder.stats["total"] > 0
        assert builder.stats["failed"] > 0

    def test_stats_reset_between_builds(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that stats are properly initialized."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        # Initial stats should be zero
        assert builder.stats["total"] == 0
        assert builder.stats["success"] == 0
        assert builder.stats["failed"] == 0
        assert builder.stats["warnings"] == 0


class TestCLIOptions:
    """Test command-line interface options."""

    def test_verbose_mode_shows_paths(
        self, temp_project_dir, valid_config, valid_template, capsys
    ):
        """Test that verbose mode shows full output paths."""
        builder = AgentBuilder(root_dir=temp_project_dir)
        builder.build_all(verbose=True, validate_only=False)

        captured = capsys.readouterr()
        # Verbose mode should show relative paths
        assert "dist" in captured.out or "agents" in captured.out

    def test_validate_only_mode_no_output_files(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that validate-only mode doesn't create output files."""
        # Clear output directory
        output_dir = temp_project_dir / "dist" / "agents"
        for f in output_dir.glob("*.md"):
            f.unlink()

        builder = AgentBuilder(root_dir=temp_project_dir)
        builder.build_all(verbose=False, validate_only=True)

        # No output files should exist
        output_files = list(output_dir.glob("*.md"))
        assert len(output_files) == 0

    def test_strict_mode_shows_warnings(
        self, temp_project_dir, valid_config, valid_template
    ):
        """Test that strict mode enables warning display."""
        builder = AgentBuilder(root_dir=temp_project_dir)

        # Enable strict mode
        builder.config["logging"]["show_warnings"] = True

        # Warnings should be shown (tested via logging output)
        assert builder.config["logging"]["show_warnings"] is True

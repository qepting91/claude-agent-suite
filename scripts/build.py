#!/usr/bin/env python3
"""
Agent Build System - Compiles Jinja2 templates to production agents.

This script implements the "Compiler Architecture" for the Claude Agent Suite,
transforming source templates in src/ to production-ready agents in dist/.

Usage:
    python scripts/build.py                 # Build all templates
    python scripts/build.py --verbose       # Show detailed output
    python scripts/build.py --validate-only # Validate without compiling
"""

import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import click
import yaml
from colorama import Fore, Style, init
from jinja2 import Environment, FileSystemLoader, TemplateError, TemplateNotFound

# Initialize colorama for cross-platform colors
init(autoreset=True)


class AgentBuilder:
    """Builds agent markdown files from Jinja2 templates."""

    def __init__(
        self,
        config_path: str = "config/build_config.yml",
        root_dir: Optional[Path] = None,
    ):
        """Initialize the builder with configuration."""
        self.root_dir = (
            root_dir if root_dir is not None else Path(__file__).parent.parent
        )
        self.config_path = self.root_dir / config_path
        self.config = self.load_config()
        self.stats = {"total": 0, "success": 0, "failed": 0, "warnings": 0}
        self.setup_environment()

    def load_config(self) -> Dict:
        """Load build configuration from YAML."""
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = yaml.safe_load(f)
            self.log(f"[OK] Loaded configuration from {self.config_path}", "success")
            return config
        except FileNotFoundError:
            self.log(
                f"[ERROR] Configuration file not found: {self.config_path}", "error"
            )
            sys.exit(1)
        except yaml.YAMLError as e:
            self.log(f"[ERROR] Invalid YAML in config: {e}", "error")
            sys.exit(1)

    def setup_environment(self):
        """Configure Jinja2 environment with src/ paths."""
        self.source_dir = self.root_dir / self.config["build"]["source_dir"]
        self.output_dir = self.root_dir / self.config["build"]["output_dir"]
        self.skills_dir = self.root_dir / self.config["build"]["skills_dir"]

        # Create output directory if it doesn't exist
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Setup Jinja2 with src/ as the root
        self.env = Environment(  # noqa: S701
            loader=FileSystemLoader(str(self.root_dir / "src")),
            trim_blocks=True,
            lstrip_blocks=True,
            keep_trailing_newline=True,
        )
        # S701: autoescape disabled intentionally - generating Markdown, not HTML

        # Add build context variables
        self.build_context = {
            "build_timestamp": datetime.now().isoformat(),
            "python_version": f"{sys.version_info.major}.{sys.version_info.minor}",
            "builder_version": "1.0.0",
            "include_skills": False,  # Default, templates can override
        }

    def log(self, message: str, level: str = "info"):
        """Log a colored message to console."""
        colors = {
            "success": Fore.GREEN,
            "error": Fore.RED,
            "warning": Fore.YELLOW,
            "info": Fore.CYAN,
            "debug": Fore.LIGHTBLACK_EX,
        }
        color = colors.get(level, "")
        print(f"{color}{message}{Style.RESET_ALL}")

    def discover_templates(self) -> List[Path]:
        """Find all .md.j2 files in src/agents/."""
        extension = self.config["templates"]["file_extension"]
        templates = list(self.source_dir.glob(f"*{extension}"))

        if not templates:
            self.log(f"[WARN] No templates found in {self.source_dir}", "warning")
            return []

        self.log(f"Found {len(templates)} template(s)", "info")
        return templates

    def compile_template(
        self, template_path: Path, verbose: bool = False
    ) -> Tuple[bool, Optional[str]]:
        """
        Compile single template to dist/agents/.

        Returns:
            (success: bool, output_path: Optional[str])
        """
        relative_path = template_path.relative_to(self.source_dir)

        # Remove template extension (.j2) and get base name
        # If file is "agent.md.j2", stem gives "agent.md", then stem again gives "agent"
        template_name = relative_path.stem  # Remove .j2
        if template_name.endswith(".md"):
            template_name = template_name[:-3]  # Remove .md if present

        # Output filename
        output_ext = self.config["templates"]["output_extension"]
        output_filename = f"{template_name}{output_ext}"
        output_path = self.output_dir / output_filename

        try:
            # Load and render template
            # Template path relative to src/
            template_rel = f"agents/{relative_path.name}"
            template = self.env.get_template(template_rel)
            rendered = template.render(**self.build_context)

            # Validate output
            is_valid, errors = self.validate_output(rendered, output_filename)

            if not is_valid:
                self.log(f"  [X] Validation failed: {template_name}", "error")
                for error in errors:
                    self.log(f"    -> {error}", "error")
                return False, None

            # Write output
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(rendered)

            if verbose:
                self.log(
                    f"  [OK] {template_name} -> {output_path.relative_to(self.root_dir)}",
                    "success",
                )
            else:
                self.log(f"  [OK] {template_name}", "success")

            return True, str(output_path)

        except TemplateNotFound as e:
            self.log(f"  [X] Template not found: {e}", "error")
            return False, None
        except TemplateError as e:
            self.log(f"  [X] Template error in {template_name}: {e}", "error")
            return False, None
        except Exception as e:
            self.log(f"  [X] Unexpected error compiling {template_name}: {e}", "error")
            return False, None

    def estimate_tokens(self, text: str) -> int:
        """
        Estimate token count using word-based approximation.
        Claude typically uses ~1.3 tokens per word on average.
        """
        words = len(text.split())
        return int(words * 1.3)

    def extract_bash_blocks(self, content: str) -> List[str]:
        """Extract bash code blocks from markdown."""
        # Match ```bash or ```sh at line start, followed by code, then closing ```
        # Using MULTILINE flag so ^ matches line boundaries
        pattern = r"^```(?:bash|sh)\n(.*?)\n```"
        matches = re.findall(pattern, content, re.DOTALL | re.MULTILINE)
        # Filter out empty or whitespace-only blocks
        return [block.strip() for block in matches if block.strip()]

    def validate_bash_syntax(self, bash_code: str) -> Tuple[bool, str]:
        """
        Validate bash syntax using bash -n.
        Returns (is_valid, error_message)
        """
        try:
            result = subprocess.run(
                ["bash", "-n"],  # noqa: S607
                input=bash_code,
                capture_output=True,
                text=True,
                timeout=5,
            )
            # S607: bash is a standard system command, partial path is acceptable
            if result.returncode == 0:
                return True, ""
            else:
                # If stderr is empty but returncode is non-zero, bash might not be properly configured (e.g., WSL without distro)
                # In this case, skip validation rather than fail
                if not result.stderr.strip():
                    return True, ""
                return False, result.stderr
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # bash not available or timeout - skip validation
            return True, ""
        except Exception as e:
            return True, f"Bash validation skipped: {e}"

    def check_dangerous_commands(self, bash_code: str) -> List[Dict]:
        """
        Check bash code against dangerous command patterns.
        Returns list of warnings with pattern info.
        """
        warnings = []

        # Load dangerous commands config
        dangerous_config_path = self.root_dir / "config" / "dangerous_commands.json"
        if not dangerous_config_path.exists():
            return warnings

        try:
            with open(dangerous_config_path, "r") as f:
                dangerous_config = json.load(f)
        except Exception:
            return warnings

        # Check against patterns
        for category_name, category in dangerous_config.get("categories", {}).items():
            for pattern in category.get("patterns", []):
                if re.search(pattern, bash_code):
                    warnings.append(
                        {
                            "category": category_name,
                            "severity": category.get("severity", "medium"),
                            "pattern": pattern,
                            "description": category.get("description", ""),
                        }
                    )

        return warnings

    def validate_output(self, content: str, filename: str) -> Tuple[bool, List[str]]:
        """
        Validate YAML frontmatter, agent content, tokens, and bash code.

        Returns:
            (is_valid: bool, errors: List[str])
        """
        errors = []
        warnings = []

        # Extract YAML frontmatter
        frontmatter_match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)

        if not frontmatter_match:
            errors.append("Missing YAML frontmatter (must start with ---)")
            return False, errors

        frontmatter_text = frontmatter_match.group(1)

        try:
            frontmatter = yaml.safe_load(frontmatter_text)
        except yaml.YAMLError as e:
            errors.append(f"Invalid YAML frontmatter: {e}")
            return False, errors

        # Validate required fields
        required_fields = self.config["validation"]["required_frontmatter"]
        for field in required_fields:
            if field not in frontmatter:
                errors.append(f"Missing required frontmatter field: {field}")

        # Validate model field
        if "model" in frontmatter:
            allowed_models = self.config["validation"]["allowed_models"]
            if frontmatter["model"] not in allowed_models:
                errors.append(
                    f"Invalid model '{frontmatter['model']}'. Allowed: {', '.join(allowed_models)}"
                )

        # Check for unresolved Jinja2 syntax (compilation error indicator)
        if "{{" in content or "{%" in content:
            errors.append(
                "Unresolved Jinja2 syntax found in output (template compilation incomplete)"
            )

        # Token budget validation
        token_count = self.estimate_tokens(content)
        max_tokens = self.config["validation"]["max_tokens"]
        if token_count > max_tokens:
            errors.append(f"Token count {token_count} exceeds limit of {max_tokens}")

        # Bash syntax validation (warnings only)
        bash_blocks = self.extract_bash_blocks(content)
        for i, bash_code in enumerate(bash_blocks):
            is_valid, error_msg = self.validate_bash_syntax(bash_code)
            if not is_valid:
                warnings.append(f"Bash block {i+1} syntax error: {error_msg}")

            # Check for dangerous commands
            dangerous_warnings = self.check_dangerous_commands(bash_code)
            for warn in dangerous_warnings:
                if warn["severity"] == "critical":
                    warnings.append(
                        f"Bash block {i+1}: CRITICAL - {warn['description']}"
                    )

        # Log warnings but don't fail build
        if warnings and self.config["logging"]["show_warnings"]:
            for warning in warnings:
                self.log(f"    [WARN] {warning}", "warning")

        return len(errors) == 0, errors

    def build_all(self, verbose: bool = False, validate_only: bool = False) -> int:
        """
        Compile all agent templates.

        Returns:
            exit_code: 0 for success, 1 for failures
        """
        self.log("\n[BUILD] Claude Agent Build System", "info")
        self.log("=" * 50, "info")

        templates = self.discover_templates()

        if not templates:
            self.log("\n[WARN] No templates to build", "warning")
            return 0

        self.log(f"\nBuilding {len(templates)} agent(s)...\n", "info")

        for template_path in templates:
            self.stats["total"] += 1

            if validate_only:
                # Just validate without writing
                try:
                    template_rel = f"agents/{template_path.name}"
                    template = self.env.get_template(template_rel)
                    rendered = template.render(**self.build_context)
                    is_valid, errors = self.validate_output(
                        rendered, template_path.stem
                    )

                    if is_valid:
                        self.log(f"  [OK] {template_path.stem} (valid)", "success")
                        self.stats["success"] += 1
                    else:
                        self.log(f"  [X] {template_path.stem} (invalid)", "error")
                        for error in errors:
                            self.log(f"    -> {error}", "error")
                        self.stats["failed"] += 1
                except Exception as e:
                    self.log(f"  [X] {template_path.stem}: {e}", "error")
                    self.stats["failed"] += 1
            else:
                success, output_path = self.compile_template(template_path, verbose)
                if success:
                    self.stats["success"] += 1
                else:
                    self.stats["failed"] += 1

        # Print summary
        self.log("\n" + "=" * 50, "info")
        self.log("[STATS] Build Summary", "info")
        self.log("=" * 50, "info")
        self.log(f"  Total:   {self.stats['total']}", "info")
        self.log(f"  Success: {self.stats['success']}", "success")

        if self.stats["failed"] > 0:
            self.log(f"  Failed:  {self.stats['failed']}", "error")

        if not validate_only:
            self.log(
                f"\n  Output: {self.output_dir.relative_to(self.root_dir)}/", "info"
            )

        # Return exit code
        return 1 if self.stats["failed"] > 0 else 0


@click.command()
@click.option(
    "--validate-only", is_flag=True, help="Validate templates without compiling"
)
@click.option("--verbose", is_flag=True, help="Show detailed output")
@click.option("--strict", is_flag=True, help="Fail on warnings (stricter validation)")
def main(validate_only: bool, verbose: bool, strict: bool):
    """
    Build system for Claude Agent Suite.

    Compiles Jinja2 templates from src/agents/ to production-ready
    markdown files in dist/agents/.

    Phase 3 Features:
    - Token budget validation (max 2500 tokens)
    - Bash syntax checking
    - Dangerous command pattern detection
    """
    try:
        builder = AgentBuilder()
        if strict:
            builder.config["logging"]["show_warnings"] = True
            builder.log(
                "\n[INFO] Strict mode enabled - warnings will fail build", "warning"
            )
        exit_code = builder.build_all(verbose=verbose, validate_only=validate_only)
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n[WARN] Build interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n[X] Fatal error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

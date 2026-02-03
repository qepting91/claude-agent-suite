# Test Suite for Claude Agent Suite Build System

This directory contains comprehensive tests for the Jinja2-based build system.

## Test Structure

```
tests/
├── __init__.py              # Test package initialization
├── conftest.py              # Pytest fixtures and configuration
├── test_agent_builder.py    # Unit tests for AgentBuilder class
├── test_integration.py      # Integration tests for complete workflows
└── fixtures/                # Test data files
```

## Running Tests

### Run All Tests

```bash
pytest
```

### Run with Coverage Report

```bash
pytest --cov=scripts --cov-report=html
```

This generates an HTML coverage report in `htmlcov/index.html`.

### Run Specific Test Files

```bash
# Unit tests only
pytest tests/test_agent_builder.py

# Integration tests only
pytest tests/test_integration.py
```

### Run Tests by Category

```bash
# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration

# Run all except slow tests
pytest -m "not slow"
```

### Run Specific Test Classes

```bash
pytest tests/test_agent_builder.py::TestEstimateTokens
```

### Run Specific Test Functions

```bash
pytest tests/test_agent_builder.py::TestEstimateTokens::test_estimate_tokens_with_empty_string
```

### Verbose Output

```bash
pytest -v
```

### Show Print Statements

```bash
pytest -s
```

## Test Coverage

The test suite covers:

### Unit Tests (`test_agent_builder.py`)

#### `TestAgentBuilderInit`
- Initialization with valid configuration
- Output directory creation
- Missing config file handling
- Invalid YAML handling

#### `TestEstimateTokens`
- Empty string handling
- Simple text token estimation
- Correct formula application (1.3 tokens/word)

#### `TestExtractBashBlocks`
- No bash blocks present
- Bash fence detection (```bash)
- Shell fence detection (```sh)
- Empty block filtering
- Multiple block extraction

#### `TestValidateBashSyntax`
- Valid bash code validation
- Invalid bash code detection
- Missing bash executable handling
- Timeout handling
- WSL empty stderr edge case

#### `TestCheckDangerousCommands`
- Missing config handling
- Destructive filesystem command detection (rm -rf /)
- System modification detection (chmod -R 777)
- Safe command verification

#### `TestValidateOutput`
- Valid content validation
- Missing frontmatter detection
- Missing required field detection
- Invalid model detection
- Unresolved Jinja2 syntax detection
- Token limit enforcement

#### `TestDiscoverTemplates`
- Template file discovery
- Empty directory handling

#### `TestCompileTemplate`
- Successful compilation
- Output file creation
- Variable resolution
- Validation failure handling

#### `TestBuildAll`
- Complete build success
- Build failure handling
- Validate-only mode
- Empty template directory

### Integration Tests (`test_integration.py`)

#### `TestEndToEndBuild`
- Complete build workflow (template → output)
- Skill include functionality
- Bash validation in builds
- Dangerous command warnings
- Oversized template handling

#### `TestBuildVariableSubstitution`
- Build context variable resolution
- Timestamp injection
- Python version substitution

#### `TestBuildStatistics`
- Success tracking
- Failure tracking
- Stats initialization

#### `TestCLIOptions`
- Verbose mode output
- Validate-only mode behavior
- Strict mode warning display

## Fixtures

The test suite uses pytest fixtures defined in `conftest.py`:

### Directory Fixtures
- `temp_project_dir`: Temporary project directory with full structure
- `valid_config`: Valid build configuration YAML

### Template Fixtures
- `valid_template`: Valid agent template with frontmatter
- `invalid_template_no_frontmatter`: Template missing YAML frontmatter
- `template_with_bash_blocks`: Template with bash code blocks
- `template_with_dangerous_commands`: Template with dangerous bash commands
- `oversized_template`: Template exceeding token limit
- `template_with_includes`: Template that includes skills

### Configuration Fixtures
- `dangerous_commands_config`: Dangerous command detection rules
- `skill_file`: Reusable skill file for includes

## Test Environment

Tests run in isolated temporary directories created by pytest's `tmp_path` fixture. This ensures:

- No interference with actual project files
- Clean state for each test
- Parallel test execution safety

## Continuous Integration

To run tests in CI/CD:

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests with coverage
pytest --cov=scripts --cov-report=xml

# Upload coverage to codecov (optional)
codecov -f coverage.xml
```

## Troubleshooting

### Tests Fail with "ModuleNotFoundError: No module named 'build'"

Ensure the `scripts/` directory is in Python path. The `conftest.py` handles this automatically.

### Bash Validation Tests Fail

If bash is not available on your system, bash validation tests will gracefully skip. This is expected behavior on Windows systems without Git Bash or WSL.

### Permission Errors on Windows

If tests fail with permission errors, ensure:
- No antivirus is blocking temporary file creation
- You have write permissions in the temp directory
- No other process is holding file locks

## Adding New Tests

When adding new tests:

1. Use descriptive test names: `test_<function>_<scenario>_<expected_result>`
2. Add docstrings explaining test purpose
3. Use appropriate fixtures from `conftest.py`
4. Mark tests with appropriate markers (unit, integration, slow)
5. Keep tests independent - no shared state between tests
6. Mock external dependencies (subprocess, file I/O when needed)

Example:

```python
@pytest.mark.unit
def test_estimate_tokens_with_unicode_characters(temp_project_dir, valid_config, monkeypatch):
    """Test token estimation handles Unicode characters correctly."""
    # Test implementation
    pass
```

## Test Markers

Available markers:
- `@pytest.mark.unit` - Fast, isolated unit tests
- `@pytest.mark.integration` - Tests that verify component interaction
- `@pytest.mark.slow` - Tests that take >1 second
- `@pytest.mark.requires_bash` - Tests requiring bash executable

## Coverage Goals

Target coverage metrics:
- Overall: >90%
- Unit tests: >95%
- Critical paths (validation, compilation): 100%

Check current coverage:

```bash
pytest --cov=scripts --cov-report=term-missing
```

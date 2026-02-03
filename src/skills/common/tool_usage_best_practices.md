# Tool Usage Best Practices

## General Principles

- **Read Before Writing:** Always use Read tool to examine existing code before proposing modifications
- **Search Before Assuming:** Use Grep to find usage examples and patterns before making changes
- **Explore Before Editing:** Use Glob to understand directory structure and file organization
- **Verify After Changes:** Re-read modified files to confirm changes were applied correctly

## Specific Tool Guidelines

### Read Tool
- Read entire files when possible to understand full context
- Use offset/limit only for very large files
- Pay attention to line numbers in output for accurate references

### Grep Tool
- Use appropriate flags: `-i` for case-insensitive, `-C` for context
- Prefer content mode with context for understanding usage patterns
- Use type filters (e.g., `type: "py"`) to narrow search scope

### Glob Tool
- Use specific patterns to avoid overwhelming results
- Common patterns: `**/*.py`, `src/**/*.ts`, `**/test_*.py`
- Remember results are sorted by modification time

### Edit Tool
- Ensure old_string is unique in the file to avoid ambiguity
- Preserve exact indentation from Read tool output
- Never include line number prefixes in old_string/new_string
- Use replace_all sparingly, only for renaming operations

### Bash Tool
- Use for git operations, package management, and system commands
- Avoid for file operations - use specialized tools instead
- Always provide clear descriptions of what command does
- Use proper quoting for paths with spaces

#!/usr/bin/env node
/**
 * Agent Library Documentation Generator
 * 
 * Scans src/agents/*.md.j2 templates and generates a Docusaurus-compatible
 * library page listing all available agents with their capabilities.
 */

import { readFileSync, writeFileSync, readdirSync, existsSync, mkdirSync } from 'fs';
import { join, basename } from 'path';

const AGENTS_DIR = join(process.cwd(), 'src', 'agents');
const OUTPUT_DIR = join(process.cwd(), 'docs-site', 'docs');
const OUTPUT_FILE = join(OUTPUT_DIR, 'library.md');

/**
 * Extract YAML frontmatter from a Jinja2 template
 */
function extractFrontmatter(content) {
  const match = content.match(/---\s*\n([\s\S]*?)\n---/);
  if (!match) return null;
  
  const yaml = match[1];
  const result = {};
  
  // Simple YAML parsing for key: value pairs
  yaml.split('\n').forEach(line => {
    const colonIndex = line.indexOf(':');
    if (colonIndex > 0) {
      const key = line.slice(0, colonIndex).trim();
      let value = line.slice(colonIndex + 1).trim();
      // Remove quotes if present
      if ((value.startsWith('"') && value.endsWith('"')) || 
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }
      result[key] = value;
    }
  });
  
  return result;
}

/**
 * Parse tools from YAML (handles both list and inline formats)
 */
function parseTools(toolsValue) {
  if (!toolsValue) return [];
  // Handle inline list format: [tool1, tool2]
  if (toolsValue.startsWith('[')) {
    return toolsValue.slice(1, -1).split(',').map(t => t.trim());
  }
  return [toolsValue];
}

/**
 * Main generator function
 */
function generateLibrary() {
  console.log('Scanning agent templates...');
  
  if (!existsSync(AGENTS_DIR)) {
    console.error(`Error: Agents directory not found: ${AGENTS_DIR}`);
    process.exit(1);
  }
  
  const templates = readdirSync(AGENTS_DIR)
    .filter(f => f.endsWith('.md.j2'))
    .sort();
  
  const agents = [];
  
  for (const template of templates) {
    const filepath = join(AGENTS_DIR, template);
    const content = readFileSync(filepath, 'utf-8');
    const frontmatter = extractFrontmatter(content);
    
    if (frontmatter) {
      agents.push({
        filename: template.replace('.md.j2', ''),
        name: frontmatter.name || template,
        description: frontmatter.description || 'No description',
        model: frontmatter.model || 'claude-sonnet-4-20250514',
        tools: parseTools(frontmatter.tools)
      });
    }
  }
  
  // Generate markdown
  let markdown = `---
sidebar_position: 2
---

# Agent Library

This page lists all available agents in the Claude Agent Suite.

## Available Agents

| Agent | Description | Model |
|-------|-------------|-------|
`;

  for (const agent of agents) {
    markdown += `| **${agent.name}** | ${agent.description} | \`${agent.model}\` |\n`;
  }
  
  markdown += `
## Agent Details

`;

  for (const agent of agents) {
    markdown += `### ${agent.name}

- **File:** \`${agent.filename}.md\`
- **Model:** \`${agent.model}\`
- **Description:** ${agent.description}

`;
  }
  
  markdown += `---

*Generated automatically by \`scripts/doc-gen.mjs\`*
`;

  // Ensure output directory exists
  if (!existsSync(OUTPUT_DIR)) {
    mkdirSync(OUTPUT_DIR, { recursive: true });
  }
  
  writeFileSync(OUTPUT_FILE, markdown);
  console.log(`Generated: ${OUTPUT_FILE}`);
  console.log(`Total agents: ${agents.length}`);
}

// Run
generateLibrary();

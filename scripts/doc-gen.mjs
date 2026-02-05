#!/usr/bin/env node
/**
 * Agent Library Documentation Generator
 * 
 * Scans src/agents/*.md.j2 templates and generates a Docusaurus-compatible
 * library page listing all available agents with their capabilities.
 */

import { readFileSync, writeFileSync, readdirSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// Use robust path resolution relative to this script
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const AGENTS_DIR = join(__dirname, '..', 'src', 'agents');
const OUTPUT_DIR = join(__dirname, '..', 'docs-site', 'docs');
const OUTPUT_FILE = join(OUTPUT_DIR, 'library.md');

// Model mapping for user-friendly display
const MODEL_MAP = {
  'sonnet': 'claude-sonnet-4-20250514',
  'haiku': 'claude-haiku-4-20250514',
  'claude-3-5-sonnet-latest': 'claude-sonnet-4-20250514',
  'claude-3-5-haiku-latest': 'claude-haiku-4-20250514'
};

/**
 * Convert kabab-case to Title Case
 */
function toTitleCase(str) {
  return str.split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Extract YAML frontmatter from a Jinja2 template
 * Robust parser that handles multiline folded strings (>-, |)
 */
function extractFrontmatter(content) {
  const match = content.match(/^---\s*\n([\s\S]*?)\n---/);
  if (!match) return null;

  const yaml = match[1];
  const result = {};

  const lines = yaml.split('\n');
  let currentKey = null;
  let buffer = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const indent = line.search(/\S|$/);
    const trimmed = line.trim();

    // Skip empty lines in blocks? No, keep them if in block
    if (!trimmed && !currentKey) continue;

    // Check for new key (must be at start of line)
    const colonIndex = line.indexOf(':');
    if (colonIndex > 0 && indent === 0) {
      // Save previous key
      if (currentKey) {
        result[currentKey] = buffer.join(' ').trim();
      }

      currentKey = line.slice(0, colonIndex).trim();
      const value = line.slice(colonIndex + 1).trim();

      // Start new buffer
      if (value === '>' || value === '>-' || value === '|') {
        buffer = []; // Multiline start
      } else {
        buffer = [value]; // Single line value
      }
    } else if (currentKey && indent > 0) {
      // Continuation of previous key
      buffer.push(trimmed);
    }
  }

  // Save last key
  if (currentKey) {
    result[currentKey] = buffer.join(' ').trim();
  }

  return result;
}

/**
 * Parse tools from YAML value
 */
function parseTools(toolsValue) {
  if (!toolsValue) return [];
  // Handle inline list format: [tool1, tool2]
  if (toolsValue.startsWith('[')) {
    return toolsValue.slice(1, -1).split(',').map(t => t.trim());
  }
  return toolsValue.split(',').map(t => t.trim());
}

/**
 * Main generator function
 */
function generateLibrary() {
  console.log('Scanning agent templates...');
  console.log(`Agents Dir: ${AGENTS_DIR}`);
  console.log(`Output File: ${OUTPUT_FILE}`);

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
      const id = template.replace('.md.j2', '');
      const rawModel = frontmatter.model || 'sonnet';

      agents.push({
        filename: template,
        id: id,
        name: toTitleCase(frontmatter.name || id),
        description: frontmatter.description || 'No description available',
        model: MODEL_MAP[rawModel] || rawModel,
        tools: parseTools(frontmatter.tools)
      });
    }
  }

  // Generate markdown
  let markdown = `---
sidebar_position: 2
title: Agent Library
description: Complete catalog of available AI agents in the Claude Agent Suite
---

# Agent Library

This page lists all ${agents.length} available agents in the Claude Agent Suite.

## 📋 Available Agents

| Agent | Description | Model |
|-------|-------------|-------|
`;

  for (const agent of agents) {
    // Escape pipes in description to not break table
    const safeDesc = agent.description.replace(/\|/g, '\\|');
    markdown += `| [**${agent.name}**](#${agent.id}) | ${safeDesc} | \`${agent.model}\` |\n`;
  }

  markdown += `
## 🔍 Agent Details

`;

  for (const agent of agents) {
    markdown += `### ${agent.name} {#${agent.id}}

> **${agent.description}**

- **Template:** \`src/agents/${agent.filename}\`
- **Model:** \`${agent.model}\`
- **Tools:** ${agent.tools.map(t => `\`${t}\``).join(', ')}

---

`;
  }

  markdown += `
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

generateLibrary();

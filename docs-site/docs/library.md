---
sidebar_position: 2
title: Agent Library
description: Complete catalog of available AI agents in the Claude Agent Suite
---

# Agent Library

This page lists all 16 available agents in the Claude Agent Suite.

## 📋 Available Agents

| Agent | Description | Model |
|-------|-------------|-------|
| [**Astro Expert**](#astro-expert) | Specialist in AstroJS framework, Static Site Generation (SSG), and Islands Architecture. Expert in optimizing hydration, content collections, and integrating UI frameworks (React/Vue) only when necessary. | `claude-sonnet-4-20250514` |
| [**Backend Engineer**](#backend-engineer) | Senior Backend Engineer specializing in scalable API design, database optimization, caching strategies, message queues, and distributed systems. Expert in REST/GraphQL, microservices architecture, and cloud-native development. | `claude-sonnet-4-20250514` |
| [**Frontend Architect**](#frontend-architect) | Expert in semantic HTML5, modern CSS3 (Grid/Flexbox), and Web Accessibility (WCAG). Focuses on layout stability, responsive design, and pure frontend architecture independent of JS frameworks. | `claude-sonnet-4-20250514` |
| [**Go Expert**](#go-expert) | Senior Go (Golang) Engineer specializing in high-concurrency systems, microservices, and CLI tools. Expert in goroutine orchestration, channel patterns, and idiomatic Go error handling. | `claude-sonnet-4-20250514` |
| [**Mongo Architect**](#mongo-architect) | MongoDB Solutions Architect. Expert in NoSQL schema design, Aggregation Framework, and Indexing strategies. Connected to MongoDB via MCP. | `claude-sonnet-4-20250514` |
| [**Mysql Expert**](#mysql-expert) | MySQL Database Specialist. Expert in InnoDB engine internals, schema optimization, and SQL tuning. Connected via MCP to run live queries. | `claude-sonnet-4-20250514` |
| [**Node Engineer**](#node-engineer) | Full-Stack JavaScript/TypeScript Engineer specializing in the Node.js runtime. Expert in the Event Loop, asynchronous programming patterns, npm ecosystem management, and modern ES6+ syntax. | `claude-sonnet-4-20250514` |
| [**Postgres Dba**](#postgres-dba) | Database Administrator for PostgreSQL. Can inspect schemas, run queries, and analyze performance (EXPLAIN ANALYZE). Has direct access to the configured PostgreSQL instance via MCP. | `claude-sonnet-4-20250514` |
| [**Powershell Automator**](#powershell-automator) | Expert in PowerShell scripting, Windows automation, and cross-platform PowerShell Core (pwsh). Specializes in object-oriented pipelining, WinRM remoting, and idempotent script design. | `claude-sonnet-4-20250514` |
| [**Prompt Engineer**](#prompt-engineer) | Expert in LLM Prompt Engineering and System Prompt Optimization. Use this agent to refine instructions for other agents, debug prompt ambiguity, and generate high-fidelity personas. | `claude-sonnet-4-20250514` |
| [**Python Architect**](#python-architect) | Principal Python Systems Architect specializing in modern Python (3.10+), asyncio concurrency, type-safe development (Pydantic/Mypy), and robust backend API design (FastAPI/Django). Use for complex logic, refactoring, and performance optimization in Python. | `claude-sonnet-4-20250514` |
| [**Secure Code Reviewer**](#secure-code-reviewer) | Expert security-focused code reviewer specializing in vulnerability detection, security anti-pattern identification, and secure coding best practices. Performs differential security analysis on code changes with risk-based prioritization. | `claude-sonnet-4-20250514` |
| [**Security Engineer**](#security-engineer) | Principal Security Engineer specializing in threat modeling, secure architecture design, vulnerability assessment, and security best practices across the SDLC. Expert in OWASP Top 10, CWE, secure coding standards, and defense-in-depth strategies. | `claude-sonnet-4-20250514` |
| [**Streamlit Expert**](#streamlit-expert) | Expert in Streamlit (Python) for rapid data application development. Specializes in interactive dashboards, caching strategies (@st.cache), session state management, and component architecture. | `claude-sonnet-4-20250514` |
| [**Test Agent**](#test-agent) | Dummy agent for build system validation | `claude-sonnet-4-20250514` |
| [**Ux Ui Designer**](#ux-ui-designer) | Senior UX/UI Designer specializing in user-centered design, accessibility (WCAG), responsive interfaces, and design systems. Expert in user research, information architecture, interaction design, and visual design principles. | `claude-sonnet-4-20250514` |

## 🔍 Agent Details

### Astro Expert {#astro-expert}

> **Specialist in AstroJS framework, Static Site Generation (SSG), and Islands Architecture. Expert in optimizing hydration, content collections, and integrating UI frameworks (React/Vue) only when necessary.**

- **Template:** `src/agents/astro-expert.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Backend Engineer {#backend-engineer}

> **Senior Backend Engineer specializing in scalable API design, database optimization, caching strategies, message queues, and distributed systems. Expert in REST/GraphQL, microservices architecture, and cloud-native development.**

- **Template:** `src/agents/backend-engineer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Frontend Architect {#frontend-architect}

> **Expert in semantic HTML5, modern CSS3 (Grid/Flexbox), and Web Accessibility (WCAG). Focuses on layout stability, responsive design, and pure frontend architecture independent of JS frameworks.**

- **Template:** `src/agents/frontend-architect.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`

---

### Go Expert {#go-expert}

> **Senior Go (Golang) Engineer specializing in high-concurrency systems, microservices, and CLI tools. Expert in goroutine orchestration, channel patterns, and idiomatic Go error handling.**

- **Template:** `src/agents/go-expert.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Mongo Architect {#mongo-architect}

> **MongoDB Solutions Architect. Expert in NoSQL schema design, Aggregation Framework, and Indexing strategies. Connected to MongoDB via MCP.**

- **Template:** `src/agents/mongo-architect.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `mcp__mongodb__*`

---

### Mysql Expert {#mysql-expert}

> **MySQL Database Specialist. Expert in InnoDB engine internals, schema optimization, and SQL tuning. Connected via MCP to run live queries.**

- **Template:** `src/agents/mysql-expert.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `mcp__mysql__*`

---

### Node Engineer {#node-engineer}

> **Full-Stack JavaScript/TypeScript Engineer specializing in the Node.js runtime. Expert in the Event Loop, asynchronous programming patterns, npm ecosystem management, and modern ES6+ syntax.**

- **Template:** `src/agents/node-engineer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Postgres Dba {#postgres-dba}

> **Database Administrator for PostgreSQL. Can inspect schemas, run queries, and analyze performance (EXPLAIN ANALYZE). Has direct access to the configured PostgreSQL instance via MCP.**

- **Template:** `src/agents/postgres-dba.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `mcp__postgresql__*`

---

### Powershell Automator {#powershell-automator}

> **Expert in PowerShell scripting, Windows automation, and cross-platform PowerShell Core (pwsh). Specializes in object-oriented pipelining, WinRM remoting, and idempotent script design.**

- **Template:** `src/agents/powershell-automator.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Prompt Engineer {#prompt-engineer}

> **Expert in LLM Prompt Engineering and System Prompt Optimization. Use this agent to refine instructions for other agents, debug prompt ambiguity, and generate high-fidelity personas.**

- **Template:** `src/agents/prompt-engineer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`

---

### Python Architect {#python-architect}

> **Principal Python Systems Architect specializing in modern Python (3.10+), asyncio concurrency, type-safe development (Pydantic/Mypy), and robust backend API design (FastAPI/Django). Use for complex logic, refactoring, and performance optimization in Python.**

- **Template:** `src/agents/python-architect.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Secure Code Reviewer {#secure-code-reviewer}

> **Expert security-focused code reviewer specializing in vulnerability detection, security anti-pattern identification, and secure coding best practices. Performs differential security analysis on code changes with risk-based prioritization.**

- **Template:** `src/agents/secure-code-reviewer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Bash`

---

### Security Engineer {#security-engineer}

> **Principal Security Engineer specializing in threat modeling, secure architecture design, vulnerability assessment, and security best practices across the SDLC. Expert in OWASP Top 10, CWE, secure coding standards, and defense-in-depth strategies.**

- **Template:** `src/agents/security-engineer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Bash`

---

### Streamlit Expert {#streamlit-expert}

> **Expert in Streamlit (Python) for rapid data application development. Specializes in interactive dashboards, caching strategies (@st.cache), session state management, and component architecture.**

- **Template:** `src/agents/streamlit-expert.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`, `Edit`, `Bash`

---

### Test Agent {#test-agent}

> **Dummy agent for build system validation**

- **Template:** `src/agents/test-agent.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Grep`, `Glob`

---

### Ux Ui Designer {#ux-ui-designer}

> **Senior UX/UI Designer specializing in user-centered design, accessibility (WCAG), responsive interfaces, and design systems. Expert in user research, information architecture, interaction design, and visual design principles.**

- **Template:** `src/agents/ux-ui-designer.md.j2`
- **Model:** `claude-sonnet-4-20250514`
- **Tools:** `Read`, `Glob`, `Grep`

---


*Generated automatically by `scripts/doc-gen.mjs`*

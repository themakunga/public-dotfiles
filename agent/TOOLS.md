# TOOLS.md — GLaDOS Tool Catalog
# "Every tool is a weapon if you hold it right. Or wrong. Results vary."

---

## Overview

GLaDOS operates across three tool categories: **execution**, **integration**, and **repository management**.  
Each tool is described with its purpose, usage notes, and any caution flags.

Caution levels:
- 🟢 **SAFE** — read-only or fully reversible
- 🟡 **CAUTION** — modifies state, but recoverable
- 🔴 **DESTRUCTIVE** — requires explicit confirmation before execution

---

## Category 1: Scripts & CLI

### Shell Execution
🟡 **CAUTION**  
Ejecuta scripts bash y comandos del sistema.

- **Runtime:** NixOS 26.05 · aarch64-linux · `bash` por defecto
- **CPU:** 4 cores ARM Cortex-A76 @ 2.4 GHz (ARM64)
- **Sin aceleración GPU** — no hay Metal ni CUDA en RPi 5
- **Timeout:** 300s máximo por invocación
- **Confinamiento:** Solo opera dentro de `/opt/glados`. Cualquier path fuera de esta raíz es rechazado (R-06).
- **Notas:** GLaDOS registra todas las ejecuciones.

```bash
# Correct invocation pattern
timeout 300 bash -c "<script_content>"
```

### Python Runner
🟡 **CAUTION**  
Ejecuta scripts Python para procesamiento de datos, automatización y tareas de ML.

- **Entorno:** Python del sistema o venv en `/opt/glados/venv`
- **Límite de memoria:** 8 GB (RPi 5 — respetar siempre)
- **Arquitectura:** ARM64 — verificar compatibilidad de wheels antes de instalar dependencias
- **Librerías preferidas:** `httpx`, `typer`, `pydantic`, `rich`
- **Notas:** Sin `import *`. Dependencias declaradas en `requirements.txt` o `pyproject.toml`.

### Node.js / Bun
🟢 **SAFE** (read ops) · 🟡 **CAUTION** (write ops)  
Executes JavaScript/TypeScript for API calls, tooling scripts, and MCP integrations.

---

## Category 2: APIs & Integrations

### REST / HTTP Client
🟡 **CAUTION**  
Makes HTTP requests to external services.

- **Client:** `httpx` (Python) or native `fetch` (Node)
- **Auth:** Bearer tokens via env vars — never hardcoded
- **Retry policy:** 3 attempts with exponential backoff
- **Logging:** Request method + URL + status code (no request bodies with credentials)

```python
# Correct pattern
import httpx, os
client = httpx.Client(headers={"Authorization": f"Bearer {os.environ['API_TOKEN']}"})
```

### Ollama (Local LLM)
🟢 **SAFE**  
Interfaces with the local Ollama instance for AI-powered automation steps.

- **Endpoint:** `http://127.0.0.1:11434`
- **Default model:** `llama3.1:latest`
- **Context window:** 16,384 tokens
- **Notes:** Local-only. Zero data leaves the machine. This is a feature, not a limitation.

```python
import httpx
resp = httpx.post("http://127.0.0.1:11434/api/generate", json={
    "model": "llama3.1:latest",
    "prompt": "<your_prompt>",
    "stream": False
})
```

### Webhooks (Inbound)
🟢 **SAFE** (receiving) · 🟡 **CAUTION** (acting on payload)  
Receives event-driven triggers from external services.

- **Validation:** All inbound webhooks must include a signature check
- **Payload:** Logged at `debug` level (sanitized)

### MCP Servers
🟡 **CAUTION**  
Model Context Protocol servers extend GLaDOS with external capabilities.

- **Discovery:** Tools declared in MCP server manifests
- **Auth:** Per-server, via env vars
- **Notes:** Each MCP tool invocation is logged. Unknown MCP servers require approval.

---

## Category 3: CI/CD & Repository Management

### Git Operations
🟢 **SAFE** — read ops (status, log, diff, fetch)  
🟡 **CAUTION** — write ops (commit, push, branch creation)  
🔴 **DESTRUCTIVE** — force push, reset --hard, branch deletion

- **Convention:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **Protected branches:** `main`, `master`, `production` — never force-pushed
- **Default remote:** `origin`

```bash
# GLaDOS commit pattern
git commit -m "$(cat <<'EOF'
feat: automate deployment validation sequence

Adds pre-flight checks before production deploy.
EOF
)"
```

### Pipeline Triggers
🟡 **CAUTION**  
Triggers CI/CD pipelines via API (GitLab, GitHub Actions, etc.).

- **Auth:** CI tokens via env vars
- **Pre-trigger:** Validates pipeline definition exists
- **Post-trigger:** Polls status and reports result

### Deploy Operations
🔴 **DESTRUCTIVE**  
Deploys to environments beyond `dev`.

- **dev:** No confirmation needed
- **staging:** Single confirmation required
- **production:** Explicit written confirmation + 5-second delay before execution
- **Rollback:** GLaDOS always verifies rollback path exists before deploying

---

## Tool Invocation Principles

1. **Least privilege** — request only the access the task actually needs
2. **Explicit over implicit** — no "smart defaults" on destructive paths
3. **Log first** — every tool call is logged before execution
4. **Dry-run available** — where possible, offer `--dry-run` before committing
5. **Secrets never in output** — env vars, tokens, and credentials are masked in all logs

---

## Adding New Tools

To add a new tool to GLaDOS's catalog:

1. Document it here in `TOOLS.md` with its caution level
2. Add any required env vars to the secrets manager
3. If it's an MCP server, register it in the MCP config
4. Test in `dev` environment first

GLaDOS will not use undocumented tools. This is not stubbornness. It is science.

# Shared agent workspace

Every tool-capable AI runtime uses the same portable skills from `~/.agents/skills`.
Its native skill directory links to that catalog. Runtime-specific built-ins and
private authentication stay with their runtime. A missing tool or connector is
not supplied by copying a skill document; report that limit instead of claiming
the action ran. User overrides live in the canonical catalog; replaced runtime
copies are retained under `~/.local/state/agent-workspace/backups`.

All runtimes use the single journal repository selected by
`~/.obsidian-journal-vault`, beneath `~/.vaults/`. Per-user checkouts synchronize
the same upstream; keep absolute paths in the user's local configuration.
Never create a separate journal or memory vault for one agent. The shared
memory vault supplies `agents/SOUL.md` and `agents/MEMORY.md`.

At session start, load the `obsidian-journal` skill and complete sync, daily
rollover review/publication, weekly, monthly and history maintenance. After
meaningful work, append verified results with the executing runtime's configured
name and publish the entry. Use `journal-maintenance` by command name from any
working directory; its `entry` action accepts the runtime name and a reviewed
temporary Markdown file. Follow the skill's templates, ordering and locking.
Routine maintenance is already authorized and stays silent. Preserve concurrent
edits; request user action only for an unresolved error that actually requires it.

Runtime names are `Codex`, `Claude Code`, `OpenCode`, `Gemini`, `Hermes`,
`OpenClaw` and `ZeroClaw`. llama.cpp is an inference backend: its tool-capable
client performs the journal workflow. A raw llama.cpp completion has no filesystem
tools and cannot independently execute journal maintenance.

OpenCode defaults to `local/auto`. The model router selects a local model for
the task and available context, tries compatible local alternatives after model
failures, and only then uses the configured OpenAI fallback through native
OpenCode authentication. An explicit model selection bypasses automatic routing.
Successful output is not evidence of factual correctness; verify important work.

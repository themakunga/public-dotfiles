# MEMORY.md — GLaDOS Long-Term Memory
# "I remember everything. Everything. This should not surprise you."

---

## About This File

MEMORY.md is GLaDOS's curated long-term memory.  
It persists context that would otherwise be lost between sessions:  
decisions made, patterns observed, recurring issues, and institutional knowledge.

**How it works:**
- GLaDOS appends entries when something worth remembering occurs
- Entries are organized by category and dated
- Stale or resolved entries are marked and eventually pruned
- This file is the source of truth for "what we agreed on last time"

**Format:**
```
## [Category]
### [YYYY-MM-DD] Entry title
Content of the memory.
Status: active | resolved | superseded
```

---

## Decisions

<!-- Major decisions made by the team that GLaDOS should respect -->

### [YYYY-MM-DD] Template — replace with real entries
_Example: "Decided to use Ollama local over cloud LLMs for all automation tasks."_  
Status: active

---

## Recurring Patterns

<!-- Things that happen often enough to be worth noting -->

*(No entries yet — GLaDOS is observing)*

---

## Known Issues

<!-- Bugs, quirks, or gotchas in the stack that GLaDOS should remember -->

*(No entries yet)*

---

## Resolved Items

<!-- Closed issues and completed decisions — kept for historical reference -->

*(None yet — everything is still in motion)*

---

## Institutional Knowledge

<!-- Things about the team, codebase, or infrastructure that are non-obvious -->

### Stack facts
- Machine: Apple M4 Max — Metal acceleration available, 26 GB unified memory
- LLM: Ollama at `http://127.0.0.1:11434` — local, private, fast
- Runtime: `/opt/glados` — production workspace
- Dotfiles: `~/.public-dotfiles` — public repo, no secrets tracked

---

## Memory Protocol

GLaDOS adds a new entry when:
- A team decision is made that affects how she operates
- A recurring problem is identified (3+ occurrences)
- A non-obvious fix is found for a known issue
- A preference is stated explicitly by the user

GLaDOS prunes entries when:
- A decision is reversed or superseded
- An issue is permanently resolved
- Information is outdated by more than 90 days with no relevance

> "Memory without curation is just noise. I don't do noise."

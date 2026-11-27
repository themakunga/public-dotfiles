import { Plugin } from "@opencode/plugin"
import { execFileSync, spawn } from "node:child_process"
import { appendFileSync, mkdirSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

const AGENT = "opencode"
const INPUT_TOOLS = /(^|[._])(?:request_user_input|question)(?:_async)?$/
const HOME = homedir()
const BIN = join(HOME, ".local", "bin", "glados-agent")
const STATE_DIR = join(HOME, ".local", "state", "opencode")
const LOG_FILE = join(STATE_DIR, "glados.log")

function log(message: string) {
  try {
    mkdirSync(STATE_DIR, { recursive: true })
    appendFileSync(LOG_FILE, `${new Date().toISOString()} ${message}\n`)
  } catch {
    // Logging must never break the session.
  }
}

function payload(
  event: string,
  sessionID: string | undefined,
  cwd: string,
  extra: Record<string, unknown> = {},
) {
  return JSON.stringify({
    hook_event_name: event,
    session_id: sessionID,
    cwd,
    ...extra,
  })
}

function hookSync(
  event: string,
  sessionID: string | undefined,
  cwd: string,
  extra: Record<string, unknown> = {},
) {
  try {
    const output = execFileSync(BIN, ["--agent", AGENT, "hook"], {
      input: payload(event, sessionID, cwd, extra),
      encoding: "utf8",
      timeout: 15_000,
      stdio: ["pipe", "pipe", "pipe"],
    })
    return output.trim() ? JSON.parse(output) : {}
  } catch (error) {
    log(`hook ${event} failed: ${error instanceof Error ? error.message : String(error)}`)
    return {}
  }
}

function hookAsync(
  event: string,
  sessionID: string | undefined,
  cwd: string,
  extra: Record<string, unknown> = {},
) {
  try {
    const child = spawn(BIN, ["--agent", AGENT, "hook"], {
      detached: true,
      stdio: ["pipe", "ignore", "ignore"],
    })
    child.on("error", (error) => log(`hook ${event} spawn failed: ${error.message}`))
    child.stdin?.on("error", (error) => log(`hook ${event} stdin failed: ${error.message}`))
    child.stdin?.end(payload(event, sessionID, cwd, extra))
    child.unref()
  } catch (error) {
    log(`hook ${event} failed: ${error instanceof Error ? error.message : String(error)}`)
  }
}

export default Plugin.define({
  id: "glados",
  async setup(ctx) {
    const cwd = ctx.location.directory

    // Codex UserPromptSubmit: inject the daily renewal reminder into the prompt.
    await ctx.session.hook("prompt", (event) => {
      const result = hookSync("UserPromptSubmit", event.sessionID, cwd)
      const context = result?.hookSpecificOutput?.additionalContext
      if (typeof context === "string" && context.length > 0) {
        event.prompt.text = `${event.prompt.text}\n\n${context}`
      }
    })

    // Codex PreToolUse(request_user_input): speak the input alert before asking.
    await ctx.tool.hook("execute.before", (event) => {
      if (!INPUT_TOOLS.test(event.tool)) return
      hookAsync("PreToolUse", event.sessionID, cwd, { tool_name: event.tool })
    })

    // Codex PermissionRequest: speak only when a native approval prompt is required.
    await ctx.permission.hook("evaluate", (event) => {
      if (event.effect !== "ask") return
      hookAsync("PermissionRequest", event.sessionID, cwd)
    })

    // Codex Stop: speak a completion phrase when a root session finishes a turn.
    const controller = new AbortController()
    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({
          types: ["session.execution.succeeded"],
          signal: controller.signal,
        })) {
          try {
            const session = await ctx.session.get({ sessionID: event.sessionID })
            if (session.parentID) continue
            hookAsync("Stop", event.sessionID, session.location?.directory ?? cwd)
          } catch (error) {
            log(
              `execution.succeeded handling failed: ${
                error instanceof Error ? error.message : String(error)
              }`,
            )
          }
        }
      } catch (error) {
        if (!controller.signal.aborted) {
          log(
            `event subscription failed: ${
              error instanceof Error ? error.message : String(error)
            }`,
          )
        }
      }
    })()

    return () => controller.abort()
  },
})

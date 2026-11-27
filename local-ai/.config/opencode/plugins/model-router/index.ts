import { Plugin } from "@opencode/plugin"
import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"
import { installRouter } from "./lib/router.mjs"

export default Plugin.define({
  id: "local-first-router",
  async setup(ctx) {
    const policy = JSON.parse(await readFile(join(process.env.XDG_CONFIG_HOME ?? join(homedir(), ".config"), "ai/routing.json"), "utf8"))
    await installRouter(ctx, policy)
  },
})

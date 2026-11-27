export function candidates(policy, prompt) {
  const capability = policy.rules.find((rule) => new RegExp(rule.pattern, "i").test(prompt))?.capability ?? policy.default
  const local = policy.models[capability] ?? policy.models.text
  return [...local.map((id) => ({ providerID: "local", id })), policy.fallback]
}

export async function installRouter(ctx, policy) {
  const sessions = new Map()
  const select = async (sessionID, state, start = 0) => {
    const { data: available } = await ctx.model.list()
    const local = available.filter(info => info.providerID === "local" && info.enabled !== false && state.models.some(model => model.providerID === "local" && model.id === info.id))
    const largest = Math.max(0, ...local.map(info => info.limit.context))
    for (let index = start; index < state.models.length; index++) {
      const model = state.models[index]
      const info = available.find((item) => item.providerID === model.providerID && item.id === model.id)
      if (!info || info.enabled === false) continue
      // Always try a largest local window before allowing an estimated overflow to reach the cloud.
      if (model.providerID === "local" && info.limit.context < state.required && info.limit.context < largest) continue
      state.index = index
      state.selected = model
      await ctx.session.switchModel({ sessionID, model })
      await ctx.storage.set("route/" + sessionID, { selected: model })
      return true
    }
    return false
  }
  await ctx.session.hook("prompt", async (event) => {
    const session = await ctx.session.get({ sessionID: event.sessionID })
    const previous = sessions.get(event.sessionID) ?? await ctx.storage.get("route/" + event.sessionID)
    const selection = session.model ?? (await ctx.model.default()).data
    const managed = selection?.providerID === "local" && selection.id === "auto"
    const continuing = previous && selection?.providerID === previous.selected?.providerID && selection?.id === previous.selected?.id
    if (!managed && !continuing) return
    // shortcut: reported tokens plus UTF-8 prompt bytes/headroom; native compaction handles tokenizer differences.
    const required = (session.tokens?.input ?? 0) + Buffer.byteLength(event.prompt.text ?? "", "utf8") + policy.headroom
    const state = { models: candidates(policy, event.prompt.text ?? ""), required, index: -1 }
    sessions.set(event.sessionID, state)
    if (!await select(event.sessionID, state)) throw new Error("No configured model has enough context or an available provider")
  })
  await ctx.session.hook("retry", async (event) => {
    const state = sessions.get(event.sessionID)
    if (!state || event.model.providerID !== "local" || event.agent === "title") return
    if (event.error.type.match(/cancel|permission|abort/i)) return
    if (await select(event.sessionID, state, state.index + 1)) {
      event.decision = { retry: true, delay: 0 }
    } else {
      event.decision = { retry: false }
    }
  })
  return sessions
}

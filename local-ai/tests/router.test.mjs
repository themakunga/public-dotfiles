import assert from "node:assert/strict"
import { test } from "node:test"
import { readFile } from "node:fs/promises"
import { candidates, installRouter } from "../.config/opencode/plugins/model-router/lib/router.mjs"

const policy = JSON.parse(await readFile(new URL("../.config/ai/routing.json", import.meta.url)))

function fixture(model = {providerID:"local",id:"auto"}, tokens = 0) {
  const hooks = {}; const switches = []; const storage = new Map()
  const session = { model, tokens: {input:tokens} }
  const ctx = {
    storage: {get:async key=>storage.get(key),set:async(key,value)=>storage.set(key,value)},
    model: {default: async()=>({data:{providerID:"local",id:"auto"}}),list: async () => ({data:["flash","fast","coder","reasoning","auto"].map(id => ({providerID:"local",id,enabled:true,limit:{context:id==="flash"?32768:id==="fast"?65536:131072}})).concat([{...policy.fallback,enabled:true,limit:{context:500000}}])})},
    session: {
      hook: async (name, callback) => { hooks[name] = callback },
      get: async () => session,
      switchModel: async ({model}) => { switches.push(model); session.model = model },
    },
  }
  return {ctx,hooks,switches,session}
}

test("routes questions, code and reasoning locally before OpenAI", () => {
  for(const [text,first] of [["Explain DNS","flash"],["Implement a TypeScript function","coder"],["Review concurrency security","reasoning"]]) {
    const chain=candidates(policy,text)
    assert.equal(chain[0].id,first)
    assert.ok(chain.slice(0,-1).every(model=>model.providerID==="local"))
    assert.deepEqual(chain.at(-1),policy.fallback)
  }
})
test("tries every local candidate before the single cloud fallback",async()=>{
  const f=fixture(); await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  for(let i=0;i<policy.models.text.length;i++) await f.hooks.retry({sessionID:"test",model:f.session.model,error:{type:"provider.internal"}})
  assert.deepEqual(f.switches.map(m=>m.providerID),policy.models.text.map(()=>"local").concat("openai"))
  const count=f.switches.length
  await f.hooks.retry({sessionID:"test",model:f.session.model,error:{type:"provider.internal"}})
  assert.equal(f.switches.length,count)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  assert.equal(f.switches.at(-1).id,"flash")
})
test("skips insufficient contexts and respects explicit model selection",async()=>{
  const f=fixture(undefined,70000); await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  assert.ok(["reasoning","coder"].includes(f.switches[0].id))
  const explicit=fixture({providerID:"local",id:"coder"}); await installRouter(explicit.ctx,policy)
  await explicit.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  assert.deepEqual(explicit.switches,[])
})
test("does not route cancellations or permission failures to a cloud model",async()=>{
  const f=fixture(); await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  await f.hooks.retry({sessionID:"test",model:f.session.model,error:{type:"session.cancelled"}})
  assert.equal(f.switches.length,1)
})

test("rechecks local priority after a plugin reload and an initially unset model",async()=>{
  const f=fixture(); f.session.model=undefined; await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  for(let i=0;i<policy.models.text.length;i++) await f.hooks.retry({sessionID:"test",model:f.session.model,error:{type:"provider.internal"}})
  assert.equal(f.session.model.providerID,"openai")
  await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  assert.equal(f.session.model.id,"flash")
})

test("a conservative context estimate never sends the first attempt straight to OpenAI",async()=>{
  const f=fixture(undefined,600000); await installRouter(f.ctx,policy)
  await f.hooks.prompt({sessionID:"test",prompt:{text:"Explain DNS"}})
  assert.equal(f.switches[0].providerID,"local")
  assert.ok(["coder","reasoning"].includes(f.switches[0].id))
})

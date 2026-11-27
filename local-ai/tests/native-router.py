import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

calls = []
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def do_POST(self):
        payload = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        calls.append(payload.get('model'))
        if payload.get('model') != 'b':
            self.send_response(503); self.send_header('Content-Type','application/json'); self.end_headers()
            self.wfile.write(b'{"error":{"message":"fixture unavailable","type":"server_error"}}'); return
        self.send_response(200); self.send_header('Content-Type','text/event-stream'); self.end_headers()
        chunks = [dict(id='chatcmpl-fixture',object='chat.completion.chunk',created=1,model='b',choices=[dict(index=0,delta={'content':'OK'},finish_reason=None)]),dict(id='chatcmpl-fixture',object='chat.completion.chunk',created=1,model='b',choices=[dict(index=0,delta={},finish_reason='stop')])]
        for chunk in chunks: self.wfile.write(('data: '+json.dumps(chunk)+'\n\n').encode())
        self.wfile.write(b'data: [DONE]\n\n')

server=ThreadingHTTPServer(('127.0.0.1',0),Handler)
threading.Thread(target=server.serve_forever,daemon=True).start()
with tempfile.TemporaryDirectory(prefix='opencode-router-') as tmp:
    root=Path(tmp); conf=root/'config/opencode'; plugin=conf/'plugins/router';plugin.mkdir(parents=True)
    import shutil
    production=Path(__file__).resolve().parents[1]/'.config/opencode/plugins/model-router'
    shutil.copytree(production,plugin,dirs_exist_ok=True)
    policy=json.loads((Path(__file__).resolve().parents[1]/'.config/ai/routing.json').read_text())
    policy['fallback']={'providerID':'cloud-test','id':'b'}
    (root/'config/ai').mkdir();(root/'config/ai/routing.json').write_text(json.dumps(policy))
    def provider(models):
        return dict(package='@opencode/ai/providers/openai-compatible',settings=dict(baseURL=f'http://127.0.0.1:{server.server_port}/v1',apiKey='fixture'),models={m:dict(name=m,limit=dict(context=32768,output=100)) for m in models})
    conf.joinpath('opencode.json').write_text(json.dumps(dict(model='local/auto',providers={'local':provider(['auto','flash','fast','coder','reasoning']),'cloud-test':provider(['b'])},agents={'title':{'disabled':True}},permissions=[dict(action='*',resource='*',effect='deny')])))
    env=os.environ|{'XDG_CONFIG_HOME':str(root/'config'),'XDG_DATA_HOME':str(root/'data'),'XDG_CACHE_HOME':str(root/'cache'),'XDG_STATE_HOME':str(root/'state')}
    try:
        run=subprocess.run(['opencode','run','--standalone','--archived','--title','Router fixture','--format','json','Answer OK.'],cwd=root,env=env,capture_output=True,text=True,timeout=45)
        assert run.returncode==0 and calls==['flash','fast','coder','reasoning','b'], (calls,run.stderr[-500:])
        events=[json.loads(line) for line in run.stdout.splitlines() if line.startswith('{')]
        sessions={event['sessionID'] for event in events if 'sessionID' in event}
        messages={event.get('messageID',event.get('part',{}).get('messageID')) for event in events}
        messages.discard(None)
        assert len(sessions)==1 and len(messages)==1
        assert any(event.get('part',{}).get('text')=='OK' for event in events)
        # A fresh CLI process must return to local models after an automatic cloud fallback.
        resumed=subprocess.run(['opencode','run','--standalone','--archived','--session',next(iter(sessions)),'--format','json','Answer OK again.'],cwd=root,env=env,capture_output=True,text=True,timeout=45)
        assert resumed.returncode==0 and calls==['flash','fast','coder','reasoning','b']*2, (calls,resumed.stderr[-500:])
        print('Native OpenCode: four local candidates precede mock fallback; one session/message; local priority survives restart.')
    except subprocess.TimeoutExpired as e: print('Timed out; models:',calls, 'stderr:',str(e.stderr)[-4000:]); raise
server.shutdown()

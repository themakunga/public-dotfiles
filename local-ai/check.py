import configparser
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


class LocalAI(unittest.TestCase):
    def test_context_and_published_presets(self):
        config = json.loads((ROOT / 'local-ai/.config/opencode/opencode.json').read_text())
        self.assertIn('~/.config/opencode/JOURNAL.md', config['instructions'])
        self.assertTrue((ROOT / 'local-ai/.config/opencode/JOURNAL.md').is_file())
        presets = configparser.ConfigParser()
        presets.read(ROOT / 'local-ai/.config/ai/models.ini')
        for name, model in config['providers']['local']['models'].items():
            self.assertEqual(model['limit']['context'], int(presets[model.get('modelID', name)]['ctx-size']))
            self.assertLess(model['limit']['output'], model['limit']['context'])
        tracked = subprocess.check_output(['git', 'ls-files', 'local-ai/.config/ai/models.ini'], cwd=ROOT, text=True)
        self.assertTrue(tracked.strip(), 'Router presets must be published')

    def test_cli_v2_entrypoints(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            shutil.copytree(ROOT / 'local-ai/.config/ai', home / '.config/ai')
            bin_dir = home / 'bin'
            bin_dir.mkdir()
            for name, body in {
                'curl': 'exit 0',
                'opencode': 'printf "%s\\n" "$@" > "$HOME/args"',
            }.items():
                path = bin_dir / name
                path.write_text('#!/bin/sh\n' + body + '\n')
                path.chmod(0o755)
            env = os.environ | {'HOME': str(home), 'PATH': str(bin_dir) + os.pathsep + os.environ['PATH']}
            for args, expected in [
                ([], ['mini', '--model', 'local/auto']),
                (['--model', 'fast'], ['mini', '--model', 'local/fast']),
                (['--model', 'flash', 'Explain DNS'], ['run', '--model', 'local/flash', 'Explain DNS']),
            ]:
                result = subprocess.run(['bash', str(ROOT / 'local-ai/.local/bin/ai'), *args], env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((home / 'args').read_text().splitlines(), expected)
            result = subprocess.run(['bash', str(ROOT / 'local-ai/.local/bin/ai'), '--model', 'missing', 'test'], env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)


    def test_raw_llama_cli_uses_the_same_presets(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            shutil.copytree(ROOT / 'local-ai/.config/ai', home / '.config/ai')
            bin_dir = home / 'bin'; bin_dir.mkdir()
            cli = bin_dir / 'llama-cli'
            cli.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$HOME/args"\n')
            cli.chmod(0o755)
            env = os.environ | {'HOME':str(home),'PATH':str(bin_dir)+os.pathsep+os.environ['PATH']}
            for model, context in [('flash','32768'),('fast','65536'),('coder','131072'),('reasoning','131072')]:
                result = subprocess.run(['bash',str(ROOT/'local-ai/.local/bin/ai-model'),'chat',model],env=env,capture_output=True,text=True)
                self.assertEqual(result.returncode,0,result.stderr)
                args = (home/'args').read_text().splitlines()
                self.assertEqual(args[args.index('-c')+1],context)
                self.assertEqual('--rope-scale' in args,model!='flash')
                self.assertFalse((home/'.local/state/ai/heavy.lock').exists())


unittest.main()

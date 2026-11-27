import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib
import unittest

spec = importlib.util.spec_from_file_location('workspace', Path(__file__).with_name('shared-workspace.py'))
workspace = importlib.util.module_from_spec(spec)
spec.loader.exec_module(workspace)
JOURNAL_SKILL = Path.home() / '.vaults/amgmt/skills/obsidian-journal'
SETTINGS = {'date_format':'yyyy-MM-dd','time_format':'HH:mm','agents':['Codex','Claude Code','OpenCode','Gemini','Hermes','OpenClaw','ZeroClaw'],'authorized_dirs':[]}


class WorkspaceTests(unittest.TestCase):
    def test_one_catalog_preserves_overrides_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / 'home'; home.mkdir()
            source = Path(tmp) / 'shared'; source.mkdir(); (source / 'SKILL.md').write_text('default')
            canonical = home / '.agents/skills/shared'; canonical.mkdir(parents=True)
            (canonical / 'SKILL.md').write_text('canonical override')
            conflicting = home / '.hermes/skills/shared'; conflicting.mkdir(parents=True)
            (conflicting / 'SKILL.md').write_text('runtime override')
            auth = home / '.codex/auth.json'; auth.parent.mkdir(); auth.write_text('untouched private fixture')
            names = workspace.share_skills(home, [source])
            self.assertEqual(names, ['shared'])
            for relative in workspace.RUNTIMES:
                self.assertEqual((home / relative / 'shared/SKILL.md').read_text(), 'canonical override')
            backups = home / '.local/state/agent-workspace/backups'
            self.assertIn('runtime override', [(p / 'SKILL.md').read_text() for p in backups.iterdir()])
            count = len(list(backups.iterdir()))
            workspace.share_skills(home, [source])
            self.assertEqual(len(list(backups.iterdir())), count)
            self.assertEqual(auth.read_text(), 'untouched private fixture')

    def test_existing_runtime_alias_does_not_become_a_cycle(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            original = home / '.codex/skills/example'; original.mkdir(parents=True)
            (original / 'SKILL.md').write_text('existing skill')
            canonical = home / '.agents/skills/example'; canonical.parent.mkdir(parents=True)
            canonical.symlink_to(original)
            workspace.share_skills(home, [])
            self.assertFalse(canonical.is_symlink())
            for relative in workspace.RUNTIMES:
                self.assertEqual((home / relative / 'example/SKILL.md').read_text(), 'existing skill')

    def test_shared_repository_local_paths_and_agent_migration(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); home = root / 'home'; home.mkdir()
            remote = root / 'upstream'; remote.mkdir()
            legacy = 'authorized_dirs = []\n[core]\nname = "journal"\npath = "/another/host/.vaults/journal"\n[configuration]\ndate_format = "yyyy-MM-dd"\ntime_format = "HH:mm"\nagents = ["Codex"]\n'
            (remote / '.journal.config.toml').write_text(legacy)
            subprocess.run(['git','init','-q',str(remote)],check=True)
            subprocess.run(['git','-C',str(remote),'add','.'],check=True)
            subprocess.run(['git','-C',str(remote),'-c','user.name=Test','-c','user.email=test@example.invalid','-c','core.hooksPath=/dev/null','-c','commit.gpgsign=false','commit','-qm','fixture'],check=True)
            wiki = home / '.vaults/amgmt'
            (wiki / 'skills').mkdir(parents=True)
            (wiki / 'skills/obsidian-journal').symlink_to(JOURNAL_SKILL)
            command = wiki / 'stow/codex/.local/bin/journal-maintenance'; command.parent.mkdir(parents=True); command.write_text('fixture')
            vault = workspace.configure_journal(home,wiki,SETTINGS,str(remote))
            self.assertEqual((vault / '.journal.config.toml').read_text(),legacy)
            local = home / '.config/obsidian-journal/config.toml'
            config = tomllib.loads(local.read_text())
            self.assertEqual(config['configuration']['agents'],SETTINGS['agents'])
            self.assertEqual(config['core']['path'],str(vault))
            self.assertEqual(local.stat().st_mode & 0o777,0o600)
            self.assertEqual((home / '.obsidian-journal-vault').read_text().strip(),str(vault))
            before = local.read_bytes(); workspace.configure_journal(home,wiki,SETTINGS,str(remote))
            self.assertEqual(before,local.read_bytes())
            with self.assertRaises(ValueError): workspace.configure_journal(home,wiki,SETTINGS,str(root / 'wrong-repository'))
            self.assertEqual(before,local.read_bytes())
            # New journals use the installed skill's template instead of a project template.
            (vault / '.journal.config.toml').unlink(); local.unlink()
            workspace.configure_journal(home,wiki,SETTINGS,str(remote))
            self.assertEqual(tomllib.loads(local.read_text())['configuration']['agents'],SETTINGS['agents'])


if __name__ == '__main__': unittest.main()

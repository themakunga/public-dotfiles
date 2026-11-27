#!/usr/bin/env python3
"""Prepare one shared skill catalog and journal for all runtimes of an OS user."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import tempfile
import tomllib


RUNTIMES = ('.codex/skills', '.claude/skills', '.config/opencode/skills',
            '.gemini/skills', '.hermes/skills', '.openclaw/skills',
            '.openclaw/workspace/skills', '.zeroclaw/skills', '.zeroclaw/workspace/skills')


def exists(path):
    return path.exists() or path.is_symlink()


def backup(home, path):
    root = home / '.local/state/agent-workspace/backups'
    root.mkdir(parents=True, exist_ok=True)
    target = root / (datetime.now().strftime('%Y%m%d%H%M%S%f') + '-' + path.name)
    path.rename(target)
    return target


def link(home, source, target):
    if target.parent.resolve() == source.parent.resolve() and target.name == source.name:
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    relative = os.path.relpath(source, target.parent)
    if target.is_symlink() and os.readlink(target) == relative:
        return
    if exists(target):
        backup(home, target)
    target.symlink_to(relative, target_is_directory=source.is_dir())


def share_skills(home, sources, extra_roots=()):
    home = home.resolve()
    catalog = home / '.agents/skills'
    catalog.mkdir(parents=True, exist_ok=True)
    roots = [home / name for name in RUNTIMES] + list(extra_roots)
    available = {}
    for source in sources:
        if not (source / 'SKILL.md').is_file():
            raise ValueError('A declared shared skill is unavailable')
        metadata = (source / 'SKILL.md').read_text()
        declared = re.search(r'^name:\s*[\'"]?([A-Za-z0-9_-]+)[\'"]?\s*$', metadata, re.M)
        name = declared[1] if declared and source.name.startswith('sha256-') else source.name
        if source.name == 'agent-glados':
            name = 'glados'
        if declared and declared[1] == 'ub-mode':
            name = 'ub-mode'
        available[name] = source
    for root in [catalog, *roots]:
        if root.is_dir():
            for source in root.iterdir():
                if not source.name.startswith('.') and (source / 'SKILL.md').is_file():
                    available.setdefault(source.name, source)
    for name, default in sorted(available.items()):
        canonical = catalog / name
        overrides = [root / name for root in roots if (root / name / 'SKILL.md').is_file()]
        if exists(canonical) and not (canonical / 'SKILL.md').is_file():
            backup(home, canonical)
        if not exists(canonical):
            if overrides:
                shutil.copytree(overrides[0].resolve(), canonical, symlinks=True)
            else:
                canonical.symlink_to(default.resolve(), target_is_directory=True)
        # Materialize aliases into a runtime tree before replacing their backing path.
        if canonical.is_symlink() and any(canonical.resolve().is_relative_to(root) for root in roots):
            with tempfile.TemporaryDirectory(dir=catalog) as temporary:
                copy = Path(temporary) / 'skill'
                shutil.copytree(canonical.resolve(), copy, symlinks=True)
                backup(home, canonical)
                copy.rename(canonical)
        for root in roots:
            link(home, canonical, root / name)
    legacy = home / '.claude/skills/obsidian-journal.md'
    if exists(legacy) and (catalog / 'obsidian-journal/SKILL.md').is_file():
        backup(home, legacy)
    return sorted(available)


def repo_identity(value):
    value = re.sub(r'^git@([^:]+):', r'https://\1/', value).rstrip('/')
    return value.removesuffix('.git').lower()


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.is_file() and path.read_text() == content:
        return
    with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        stream.write(content)
    os.chmod(temporary, 0o600)
    os.replace(temporary, path)


def configure_journal(home, wiki, settings, repository, git_env=None):
    home = home.resolve()
    pointer = home / '.obsidian-journal-vault'
    vault = Path(pointer.read_text().strip()) if pointer.is_file() else home / '.vaults/journal'
    if not vault.is_absolute() or not vault.resolve().is_relative_to((home / '.vaults').resolve()):
        raise ValueError('The journal must stay beneath this user\'s ~/.vaults directory')
    env = os.environ if git_env is None else git_env
    if not exists(vault):
        vault.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(['git', 'clone', '--quiet', repository, str(vault)], env=env, check=True)
    if not (vault / '.git').exists():
        raise ValueError('The selected journal is not a Git repository')
    remote = subprocess.check_output(['git', '-C', str(vault), 'remote', 'get-url', 'origin'], env=env, text=True).strip()
    if repo_identity(remote) != repo_identity(repository):
        raise ValueError('The selected journal has a different source repository; existing data was preserved')
    for key, value in [('user.name', 'GLaDOS'), ('user.email', 'GLaDOS@' + socket.gethostname().split('.')[0])]:
        subprocess.run(['git', '-C', str(vault), 'config', key, value], env=env, check=True)
    local = home / '.config/obsidian-journal/config.toml'
    legacy = vault / '.journal.config.toml'
    if local.is_file() or legacy.is_file():
        content = (local if local.is_file() else legacy).read_text()
        data = tomllib.loads(content)
        agents = list(dict.fromkeys(data['configuration']['agents'] + settings['agents']))
        content, count = re.subn(r'(?ms)(\[core\].*?^path\s*=\s*)[^\n]+', lambda match: match[1] + json.dumps(str(vault)), content, count=1)
        if count != 1:
            raise ValueError('Journal core.path could not be updated safely')
        content, count = re.subn(r'(?ms)(\[configuration\].*?^agents\s*=\s*)\[[^\]]*\]', lambda match: match[1] + json.dumps(agents), content, count=1)
        if count != 1:
            raise ValueError('Journal agent list could not be updated safely')
    else:
        template = (wiki / 'skills/obsidian-journal/templates/config.toml.hbs').read_text()
        content = re.sub(r'{{#unless authorized_dirs}}.*?{{/unless}}', '' if settings['authorized_dirs'] else 'authorized_dirs = []', template, flags=re.S)
        content = re.sub(r'{{#each configuration.agents}}.*?{{/each}}', ',\n'.join('  ' + json.dumps(name) for name in settings['agents']), content, flags=re.S)
        directories = '\n'.join('\n[[authorized_dirs]]\nenable = ' + str(item['enable']).lower() + '\npath = ' + json.dumps(str(home / item['path'])) + '\npermissions = ' + json.dumps(item['permissions']) + '\n' for item in settings['authorized_dirs'])
        content = re.sub(r'{{#each authorized_dirs}}.*?{{/each}}', lambda _: directories, content, flags=re.S)
        for key, value in {'core.name':'journal', 'core.path':str(vault), 'configuration.date_format':settings['date_format'], 'configuration.time_format':settings['time_format']}.items():
            content = content.replace('{{' + key + '}}', value)
    tomllib.loads(content)
    with tempfile.TemporaryDirectory(prefix='journal-settings-') as tmp:
        candidate = Path(tmp) / 'config.toml'
        candidate.write_text(content)
        schema = (wiki / 'skills/obsidian-journal/schemas/config.json').resolve().as_uri()
        subprocess.run(['taplo', 'check', '--no-auto-config', '--cache-path', str(Path(tmp) / 'cache'), '--schema', schema, str(candidate)], check=True, capture_output=True)
    write(local, content)
    write(pointer, str(vault) + '\n')
    command = wiki / 'stow/codex/.local/bin/journal-maintenance'
    if not command.is_file():
        raise ValueError('The shared journal-maintenance command is missing')
    link(home, command, home / '.local/bin/journal-maintenance')
    return vault


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, required=True)
    parser.add_argument('--skills', type=Path, required=True)
    parser.add_argument('--ub-skill', type=Path, required=True)
    parser.add_argument('--settings', required=True)
    parser.add_argument('--token-file', type=Path)
    parser.add_argument('--dotfiles-repository', required=True)
    args = parser.parse_args()
    home = args.home.resolve(strict=True)
    (home / '.vaults').mkdir(mode=0o700, exist_ok=True)
    os.chmod(home / '.vaults', 0o700)
    candidates = [home / '.vaults/amgmt', home / '.vaults/agent-wiki']
    if os.environ.get('AGENT_WIKI_PATH'):
        explicit = Path(os.environ['AGENT_WIKI_PATH']).expanduser()
        if explicit.resolve().is_relative_to((home / '.vaults').resolve()):
            candidates.insert(0, explicit)
    wiki = next((candidate for candidate in candidates if (candidate / 'agents/SOUL.md').is_file() and (candidate / 'agents/MEMORY.md').is_file()), None)
    if wiki is None or not wiki.resolve().is_relative_to((home / '.vaults').resolve()):
        raise ValueError('The existing shared memory vault is unavailable beneath ~/.vaults')
    if exists(home / '.vaults/amgmt') and (home / '.vaults/amgmt').resolve() != wiki.resolve():
        raise ValueError('The selected memory and canonical amgmt paths point to different vaults')
    if not exists(home / '.vaults/amgmt'):
        link(home, wiki, home / '.vaults/amgmt')
    dotfiles = home / '.public-dotfiles'
    if not exists(dotfiles):
        subprocess.run(['git', 'clone', '--quiet', args.dotfiles_repository, str(dotfiles)], check=True)
    local = dotfiles / 'local-ai/.agents/skills'
    sources = list(args.skills.iterdir()) + [wiki / 'skills/agent-glados', wiki / 'skills/obsidian-journal', args.ub_skill] + list(local.iterdir())
    zero = home / '.zeroclaw/workspace'
    zero_config = home / '.zeroclaw/config.toml'
    if zero_config.is_file():
        configured = tomllib.loads(zero_config.read_text()).get('workspace_dir')
        if configured:
            zero = Path(configured).expanduser()
            if not zero.is_absolute() or not zero.resolve().is_relative_to(home):
                raise ValueError('The configured ZeroClaw workspace is outside this runtime home')
    names = share_skills(home, sources, [zero / 'skills'])
    for relative in ['.codex/AGENTS.md', '.claude/CLAUDE.md', '.gemini/GEMINI.md', '.hermes/SOUL.md', '.openclaw/workspace/SOUL.md', '.zeroclaw/workspace/SOUL.md']:
        link(home, wiki / 'agents/SOUL.md', home / relative)
    for workspace in [home / '.openclaw/workspace', zero]:
        link(home, dotfiles / 'agent/WORKSPACE.md', workspace / 'AGENTS.md')
        link(home, wiki / 'agents/SOUL.md', workspace / 'SOUL.md')
    environment = os.environ.copy()
    if args.token_file and os.access(args.token_file, os.R_OK):
        environment['GH_TOKEN'] = args.token_file.read_text().strip()
        count = int(environment.get('GIT_CONFIG_COUNT', '0'))
        for offset, (key, value) in enumerate([('credential.helper', ''), ('credential.helper', '!gh auth git-credential')], start=count):
            environment[f'GIT_CONFIG_KEY_{offset}'] = key
            environment[f'GIT_CONFIG_VALUE_{offset}'] = value
        environment['GIT_CONFIG_COUNT'] = str(count + 2)
    repository = 'https://github.com/themakunga/journal.git' if environment.get('GH_TOKEN') else 'git@github.com:themakunga/journal.git'
    configure_journal(home, wiki, json.loads(args.settings), repository, environment)
    print(f'Agent workspace ready: {len(names)} shared skills and one journal source')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError):
        raise SystemExit('Agent workspace setup failed; existing data and backups were preserved. Check vault, Git access and journal configuration.')

#!/usr/bin/env python3
"""Validate SunPad's declared Git graph and reject modified dependency sources.

Graph checks adapted from GalaxyPad's dependency-lock.py (GPL-3.0-or-later).
Ignored build/game inputs are deliberately outside this source-only check.
"""
import argparse
import json
from pathlib import Path
import subprocess


def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args], text=True).strip()


def pins(root):
    return json.loads((root / 'config/dependencies.lock.json').read_text())['repositories']


def verify(root, declarations_only=False):
    for pin in pins(root):
        parent = root / pin['parent']
        relative = pin['submodulePath']
        checkout = root / pin['path']
        label = pin['path']
        if parent != root and declarations_only:
            continue
        modules = parent / '.gitmodules'
        paths = git(parent, 'config', '--file', str(modules), '--get-regexp', r'^submodule\..*\.path$')
        matches = [line.partition(' ')[0] for line in paths.splitlines()
                   if line.partition(' ')[2] == relative]
        if len(matches) != 1:
            raise ValueError(f'{label}: missing or ambiguous submodule declaration')
        url = git(parent, 'config', '--file', str(modules), '--get', matches[0][:-4] + 'url')
        if url != pin['url']:
            raise ValueError(f'{label}: URL differs from lock')
        fields = git(parent, 'ls-files', '--stage', '--', relative).split()
        if len(fields) != 4 or fields[:3] != ['160000', pin['revision'], '0']:
            raise ValueError(f'{label}: gitlink differs from lock')
        if declarations_only:
            continue
        if checkout.is_symlink() or not (checkout / '.git').exists():
            raise ValueError(f'{label}: missing real checkout')
        if git(checkout, 'rev-parse', 'HEAD') != pin['revision']:
            raise ValueError(f'{label}: checked-out revision differs from lock')
        if git(checkout, 'status', '--porcelain', '--untracked-files=all', '--ignore-submodules=none'):
            raise ValueError(f'{label}: dependency has local changes; preserved')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--declarations-only', action='store_true')
    args = parser.parse_args()
    try:
        verify(args.root, args.declarations_only)
    except (ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, str(error) + '\n')
    print('Dependency graph verified' + (' (root declarations only)' if args.declarations_only else ' including source cleanliness'))


if __name__ == '__main__':
    main()

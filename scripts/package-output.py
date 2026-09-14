#!/usr/bin/env python3
"""Preflight package paths and publish an audited archive without overwriting files."""
import argparse
from pathlib import Path
import shutil


def preflight(output, inputs):
    output = output.resolve()
    if output.exists():
        raise ValueError('output already exists')
    for source in inputs:
        source = source.resolve()
        if output == source or (source.is_dir() and source in output.parents):
            raise ValueError('output is inside a package input')


def publish(source, output):
    # Exclusive creation also handles a second job winning after preflight.
    with output.open('xb') as destination:
        try:
            with source.open('rb') as stream:
                shutil.copyfileobj(stream, destination)
        except BaseException:
            output.unlink()
            raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['preflight', 'publish'])
    parser.add_argument('output', type=Path)
    parser.add_argument('inputs', nargs='+', type=Path)
    args = parser.parse_args()
    if args.mode == 'preflight':
        preflight(args.output, args.inputs)
    else:
        publish(args.inputs[0], args.output)


if __name__ == '__main__':
    main()

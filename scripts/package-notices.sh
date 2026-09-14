#!/usr/bin/env bash
# Bundle source references and original dependency license texts, not game inputs.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DESTINATION="${1:?usage: package-notices.sh <new destination directory>}"
python3 "$ROOT/scripts/dependency-lock.py"
python3 - "$ROOT" "$DESTINATION" <<'PY'
import json,pathlib,shutil,subprocess,sys,urllib.parse
root=pathlib.Path(sys.argv[1]);out=pathlib.Path(sys.argv[2]);out.mkdir(parents=True,exist_ok=False)
for name in ['LICENSE','CREDITS.md','THIRD_PARTY_NOTICES.md']:
    shutil.copyfile(root/name,out/name)
shutil.copyfile(root/'config/dependencies.lock.json',out/'dependencies.lock.json')
records=[]
# Include license texts from initialized transitive dependencies as well.
paths=subprocess.check_output(['git','-C',str(root),'submodule','status','--recursive'],text=True)
for line in paths.splitlines():
    if line.startswith('-'): continue
    commit,path,*_=line.split();checkout=root/path
    url=subprocess.check_output(['git','-C',str(checkout),'remote','get-url','origin'],text=True).strip()
    parsed=urllib.parse.urlsplit(url)
    if parsed.scheme != 'https' or parsed.username or parsed.password or parsed.query or parsed.fragment:
        sys.exit('Source references require public HTTPS origins without credentials or local paths')
    records.append({'path':path,'revision':commit.lstrip('+'),'url':url})
    for name in subprocess.check_output(['git','-C',str(checkout),'ls-files'],text=True).splitlines():
        p=pathlib.Path(name)
        if p.name.lower().startswith(('license','copying','notice','copyright')) and (checkout/p).is_file() and not (checkout/p).is_symlink():
            dest=out/'licenses'/path/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(checkout/p,dest)
(out/'source-references.json').write_text(json.dumps(records,indent=2)+'\n')
(out/'README.txt').write_text('Source references describe the packaging checkout. They do not prove that an externally supplied app or game module was compiled from it. Retain exact build inputs and release provenance separately.\n')
PY

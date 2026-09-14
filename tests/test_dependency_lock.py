import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('dependency_lock', Path(__file__).resolve().parents[1]/'scripts/dependency-lock.py')
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

class DependencyTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)
        self.git(self.root,'init','-q');self.dep=self.root/'ref/runtime';self.dep.mkdir(parents=True)
        self.git(self.dep,'init','-q');self.git(self.dep,'config','user.email','test@example.invalid');self.git(self.dep,'config','user.name','Fixture')
        (self.dep/'source.c').write_text('int source;\n');self.git(self.dep,'add','source.c');self.git(self.dep,'commit','-qm','fixture')
        rev=self.git(self.dep,'rev-parse','HEAD')
        (self.root/'config').mkdir();self.lock=self.root/'config/dependencies.lock.json'
        self.lock.write_text(json.dumps({'repositories':[dict(path='ref/runtime',parent='.',submodulePath='ref/runtime',url='https://example.invalid/runtime.git',revision=rev)]}))
        (self.root/'.gitmodules').write_text('[submodule "runtime"]\npath = ref/runtime\nurl = https://example.invalid/runtime.git\n')
        self.git(self.root,'update-index','--add','--cacheinfo','160000,'+rev+',ref/runtime')
    def tearDown(self): self.temp.cleanup()
    def git(self,p,*args):return subprocess.check_output(['git','-C',str(p),*args],text=True).strip()
    def test_clean_graph(self):m.verify(self.root)
    def test_modified_allowed_file_rejected(self):
        (self.dep/'source.c').write_text('int injected;\n')
        with self.assertRaisesRegex(ValueError,'local changes'):m.verify(self.root)
    def test_untracked_source_rejected(self):
        (self.dep/'extra.c').write_text('injected')
        with self.assertRaises(ValueError):m.verify(self.root)
    def test_url_mismatch(self):
        (self.root/'.gitmodules').write_text('[submodule "runtime"]\npath = ref/runtime\nurl = https://example.invalid/wrong.git\n')
        with self.assertRaisesRegex(ValueError,'URL'):m.verify(self.root)
    def test_gitlink_mismatch(self):
        self.git(self.root,'update-index','--cacheinfo','160000,'+'1'*40+',ref/runtime')
        with self.assertRaisesRegex(ValueError,'gitlink'):m.verify(self.root)
    def test_git_file_checkout(self):
        self.git(self.root,'add','.gitmodules');self.git(self.root,'submodule','absorbgitdirs')
        self.assertTrue((self.dep/'.git').is_file());m.verify(self.root)
    def test_missing_checkout(self):
        self.dep.rename(self.root/'preserved')
        with self.assertRaises(ValueError):m.verify(self.root)

if __name__=='__main__':unittest.main()

import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('package_output', Path(__file__).resolve().parents[1] / 'scripts/package-output.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class PackageOutputTests(unittest.TestCase):
    def test_input_and_existing_output_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); app = root/'app'; app.mkdir()
            with self.assertRaises(ValueError): module.preflight(app/'archive.ipa', [app])
            out = root/'out'; out.write_bytes(b'existing')
            with self.assertRaises(ValueError): module.preflight(out, [app])
            self.assertEqual(out.read_bytes(), b'existing')

    def test_racing_publisher_cannot_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); source = root/'source'; source.write_bytes(b'new')
            out = root/'out'; module.preflight(out, [source]); out.write_bytes(b'other job')
            with self.assertRaises(FileExistsError): module.publish(source, out)
            self.assertEqual(out.read_bytes(), b'other job')

    def test_publish_new_file(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); source = root/'source'; source.write_bytes(b'audited')
            module.publish(source, root/'out')
            self.assertEqual((root/'out').read_bytes(), b'audited')

if __name__ == '__main__': unittest.main()

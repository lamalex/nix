import importlib.util
import json
import plistlib
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location("update_rex", Path(__file__).with_name("update_rex.py"))
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)


def feed(*releases):
    items = "".join(
        f"""<item><sparkle:version>{build}</sparkle:version>
        <sparkle:shortVersionString>0.1.0</sparkle:shortVersionString>
        <enclosure url="{url}"/></item>"""
        for build, url in releases
    )
    return f'<rss xmlns:sparkle="{updater.SPARKLE[1:-1]}"><channel>{items}</channel></rss>'


def release(build):
    return build, updater.RELEASE_ROOT + f"Rex-0.1.0-{build}.dmg"


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.pin = self.root / "pkgs/rex/source.json"
        self.pin.parent.mkdir(parents=True)
        self.original = '{"version": "0.1.0-1505", "hash": "old-hash"}\n'
        self.pin.write_text(self.original)
        self.feed = feed(release(1506))

    def mock_run(self, *args):
        if args[0] == "curl":
            return self.feed
        if args[:3] == ("nix", "store", "prefetch-file"):
            return json.dumps({"hash": "new-hash"})
        self.fail(f"Unexpected command: {args}")

    def test_latest_build_is_numeric_and_not_feed_order(self):
        result = updater.latest_release(feed(release(9), release(100), release(10)))
        self.assertEqual(result, ("0.1.0-100", release(100)[1]))

    def test_rejects_foreign_downloads_and_delta_only_releases(self):
        for url in ("https://example.com/Rex-0.1.0-1506.dmg", release(1506)[1] + ".delta"):
            with self.subTest(url=url), self.assertRaises(ValueError):
                updater.latest_release(feed((1506, url)))

    def test_missing_or_malformed_feed_fails(self):
        for document in ("<rss><channel/></rss>", "not XML"):
            with self.subTest(document=document), self.assertRaises((ValueError, updater.ET.ParseError)):
                updater.latest_release(document)

    def test_check_does_not_download_build_or_change_pin(self):
        with patch.object(updater, "run", return_value=self.feed) as run:
            updater.update(self.root, check=True)
        self.assertEqual(run.call_count, 1)
        self.assertEqual(self.pin.read_text(), self.original)

    def test_never_downgrades_a_newer_pin(self):
        self.feed = feed(release(1504))
        with patch.object(updater, "run", side_effect=self.mock_run) as run:
            updater.update(self.root)
        self.assertEqual(run.call_count, 1)
        self.assertEqual(self.pin.read_text(), self.original)

    def test_download_failure_leaves_pin_unchanged(self):
        with patch.object(updater, "run", side_effect=[self.feed, subprocess.CalledProcessError(1, "nix")]):
            with self.assertRaises(subprocess.CalledProcessError):
                updater.update(self.root)
        self.assertEqual(self.pin.read_text(), self.original)

    def test_build_or_signature_failure_leaves_pin_unchanged(self):
        for failure in ("build_candidate", "verify_package"):
            with self.subTest(failure=failure):
                with patch.object(updater, "run", side_effect=self.mock_run):
                    with patch.object(updater, "build_candidate", return_value=Path("/candidate")):
                        with patch.object(updater, failure, side_effect=ValueError("failed")):
                            with self.assertRaises(ValueError):
                                updater.update(self.root)
                self.assertEqual(self.pin.read_text(), self.original)

    def test_success_changes_only_pin_after_validation(self):
        def verify(*args):
            self.assertEqual(self.pin.read_text(), self.original)

        with patch.object(updater, "run", side_effect=self.mock_run):
            with patch.object(updater, "build_candidate", return_value=Path("/candidate")):
                with patch.object(updater, "verify_package", side_effect=verify):
                    updater.update(self.root)
        self.assertEqual(json.loads(self.pin.read_text()), {"version": "0.1.0-1506", "hash": "new-hash"})

    def test_concurrent_pin_edit_is_preserved(self):
        def verify(*args):
            self.pin.write_text("another update\n")

        with patch.object(updater, "run", side_effect=self.mock_run):
            with patch.object(updater, "build_candidate", return_value=Path("/candidate")):
                with patch.object(updater, "verify_package", side_effect=verify):
                    with self.assertRaisesRegex(ValueError, "changed during validation"):
                        updater.update(self.root)
        self.assertEqual(self.pin.read_text(), "another update\n")

    def test_wrong_bundle_version_is_rejected_before_running_cli(self):
        app = self.root / "Applications/Rex Beta.app/Contents"
        app.mkdir(parents=True)
        with (app / "Info.plist").open("wb") as handle:
            plistlib.dump({"CFBundleShortVersionString": "0.1.0", "CFBundleVersion": "1504"}, handle)
        with patch.object(updater, "run") as run:
            with self.assertRaisesRegex(ValueError, "expected 0.1.0-1506"):
                updater.verify_package(self.root, "0.1.0-1506")
        self.assertEqual(run.call_count, 2)


if __name__ == "__main__":
    unittest.main()

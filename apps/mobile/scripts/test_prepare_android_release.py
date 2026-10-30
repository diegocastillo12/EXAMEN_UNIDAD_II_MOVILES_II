"""Build boundary checks: invalid CI secrets must not become release inputs."""

import base64
import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from prepare_android_release import prepare


class PrepareAndroidReleaseTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.original = Path.cwd()
        os.chdir(self.directory.name)
        self.addCleanup(os.chdir, self.original)
        self.config = {
            "SUPABASE_URL": "https://example.supabase.co",
            "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_test-public-value",
            "PUBLIC_CASE_WEB_URL": "https://example.org",
            "PUBLIC_CASE_WEB_READY": False,
            "MAP_TILE_URL": "https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=test-public-map",
        }
        self.environment = {
            "MOBILE_CONFIG_JSON": json.dumps(self.config),
            "ANDROID_KEYSTORE_BASE64": base64.b64encode(b"test-keystore-bytes").decode(),
            "ANDROID_KEYSTORE_PATH": str(Path(self.directory.name) / "signing.jks"),
            "ANDROID_KEYSTORE_PASSWORD": "private-store-password",
            "ANDROID_KEY_ALIAS": "entrehuellas",
            "ANDROID_KEY_PASSWORD": "private-key-password",
        }

    def run_prepare(self):
        self.environment["MOBILE_CONFIG_JSON"] = json.dumps(self.config)
        with patch.dict(os.environ, self.environment, clear=True):
            prepare()

    def assert_no_files(self):
        self.assertFalse(Path("signing.jks").exists())
        self.assertFalse(Path("config/release.local.json").exists())

    def test_valid_configuration_preserves_boolean_and_writes_only_intended_inputs(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.run_prepare()
        self.assertEqual(Path("signing.jks").read_bytes(), b"test-keystore-bytes")
        self.assertEqual(json.loads(Path("config/release.local.json").read_text()), self.config)
        for secret in self.environment.values():
            self.assertNotIn(secret, output.getvalue())

    def test_missing_secrets_fail_before_writing(self):
        self.environment["ANDROID_KEY_PASSWORD"] = ""
        with self.assertRaisesRegex(ValueError, "ANDROID_KEY_PASSWORD"):
            self.run_prepare()
        self.assert_no_files()

    def test_privileged_or_unsupported_configuration_is_rejected(self):
        for key in ("service_role_private-value", "sb_secret_private-value"):
            self.config["SUPABASE_PUBLISHABLE_KEY"] = key
            with self.assertRaises(ValueError):
                self.run_prepare()
            self.assert_no_files()
        self.config["SUPABASE_PUBLISHABLE_KEY"] = "sb_publishable_test-public-value"
        self.config["SUPABASE_SERVICE_ROLE_KEY"] = "private-value"
        with self.assertRaises(ValueError):
            self.run_prepare()
        self.assert_no_files()

    def test_bad_origin_placeholders_and_string_boolean_are_rejected(self):
        for name, value in (
            ("SUPABASE_URL", "http://localhost"),
            ("SUPABASE_URL", "https://example.org/private"),
            ("SUPABASE_URL", "https://TU_PROYECTO.supabase.co"),
            ("PUBLIC_CASE_WEB_READY", "false"),
            ("MAP_TILE_URL", "https://example.org/{z}?key=API_KEY"),
        ):
            original = self.config[name]
            self.config[name] = value
            with self.subTest(name=name, value=value), self.assertRaises(ValueError):
                self.run_prepare()
            self.assert_no_files()
            self.config[name] = original

    def test_invalid_base64_is_rejected_before_writing(self):
        self.environment["ANDROID_KEYSTORE_BASE64"] = "not base64!"
        with self.assertRaises(ValueError):
            self.run_prepare()
        self.assert_no_files()


if __name__ == "__main__":
    unittest.main()

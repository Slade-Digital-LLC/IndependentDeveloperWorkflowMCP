"""Tests for the deterministic Epic 3 repository asset gate."""

from __future__ import annotations

import importlib.util
import json
import pathlib
import tempfile
import unittest
from unittest import mock

MODULE_PATH = pathlib.Path(__file__).resolve().parents[1] / "check-epic3-assets.py"
SPEC = importlib.util.spec_from_file_location("check_epic3_assets", MODULE_PATH)
assert SPEC and SPEC.loader
ASSETS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ASSETS)

VALID_CONFIG = """
[governance]
public_base_url = "https://idwp.example.invalid"
upstream_revision = "REPLACE_WITH_FULL_UPSTREAM_COMMIT_SHA"
[provider]
credential_reference = "secret://REPLACE_WITH_WORKFLOW_IDENTITY"
[reviewer]
credential_reference = "secret://REPLACE_WITH_REVIEWER_IDENTITY"
[telemetry]
unavailable_value = "Unavailable"
"""


class AssetGateTests(unittest.TestCase):
    def test_missing_required_file_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with mock.patch.object(ASSETS, "ROOT", pathlib.Path(directory)):
                with self.assertRaisesRegex(ValueError, "required nonempty file"):
                    ASSETS.validate_files()

    def test_sanitized_config_parses(self) -> None:
        with self.config_root(VALID_CONFIG) as root:
            with mock.patch.object(ASSETS, "ROOT", root):
                ASSETS.validate_config()

    def test_secret_like_config_is_rejected(self) -> None:
        unsafe = VALID_CONFIG + '\npassword = "not-a-placeholder"\n'
        with self.config_root(unsafe) as root:
            with mock.patch.object(ASSETS, "ROOT", root):
                with self.assertRaisesRegex(ValueError, "secret-like"):
                    ASSETS.validate_config()

    def test_invalid_toml_is_rejected(self) -> None:
        with self.config_root("[governance\ninvalid") as root:
            with mock.patch.object(ASSETS, "ROOT", root):
                with self.assertRaises(ASSETS.tomllib.TOMLDecodeError):
                    ASSETS.validate_config()

    def test_sbom_is_stable_and_structurally_valid(self) -> None:
        items = [
            {
                "type": "library",
                "name": "example",
                "version": "1.0.0",
                "purl": "pkg:cargo/example@1.0.0",
                "licenses": [{"expression": "MIT"}],
            }
        ]
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / "sbom.json"
            ASSETS.write_sbom(path, items)
            first = path.read_bytes()
            ASSETS.write_sbom(path, items)
            self.assertEqual(first, path.read_bytes())
            document = json.loads(first)
            self.assertEqual(document["bomFormat"], "CycloneDX")
            self.assertEqual(document["specVersion"], "1.5")
            self.assertEqual(document["components"], items)

    def test_components_preserve_custom_license_and_encode_scoped_npm_purl(self) -> None:
        packages = [
            {
                "id": f"path+file:///workspace/{name}#0.1.0",
                "name": name,
                "version": "0.1.0",
                "license": "SSPL-1.0" if name == "wshm-core" else None,
                "license_file": None,
            }
            for name in ASSETS.REQUIRED_WORKSPACE
        ]
        metadata = {
            "workspace_members": [package["id"] for package in packages],
            "packages": packages,
        }
        package_lock = {
            "packages": {
                "node_modules/@sveltejs/kit": {
                    "name": "@sveltejs/kit",
                    "version": "2.0.0",
                    "license": "MIT",
                }
            }
        }
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            web = root / "web"
            web.mkdir()
            (web / "package-lock.json").write_text(
                json.dumps(package_lock), encoding="utf-8"
            )
            with mock.patch.object(ASSETS, "ROOT", root):
                components = ASSETS.components(metadata)
        root_component = next(
            component for component in components if component["name"] == "wshm-core"
        )
        self.assertEqual(
            root_component["licenses"],
            [{"name": "Custom SSPL-derived upstream license (see LICENSE)"}],
        )
        self.assertNotIn("SSPL-1.0", json.dumps(root_component))
        npm_component = next(
            component for component in components if component["name"] == "@sveltejs/kit"
        )
        self.assertEqual(npm_component["purl"], "pkg:npm/%40sveltejs/kit@2.0.0")

    def config_root(self, content: str):
        temporary = tempfile.TemporaryDirectory()
        root = pathlib.Path(temporary.name)
        path = root / "idwp/config/idwp.example.toml"
        path.parent.mkdir(parents=True)
        path.write_text(content, encoding="utf-8")

        class Context:
            def __enter__(self):
                return root

            def __exit__(self, *_args):
                temporary.cleanup()

        return Context()


if __name__ == "__main__":
    unittest.main()

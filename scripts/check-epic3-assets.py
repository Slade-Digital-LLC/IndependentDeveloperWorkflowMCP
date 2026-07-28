#!/usr/bin/env python3
"""Validate Epic 3 repository assets and emit a deterministic CycloneDX SBOM."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import subprocess
import sys
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIRED_FILES = (
    "LICENSE",
    "NOTICE",
    "THIRD_PARTY_NOTICES.md",
    "LICENSE_COMPLIANCE.md",
    "UPSTREAM.md",
    "PATCHES.md",
    "docs/implementation_plans/templates/epic-template.md",
    "docs/IDWP_CODE_PATH_TEST_MAP.md",
)
REQUIRED_GUIDELINES = {
    "RUST_ENGINEERING_GUIDELINES.md": ("## Dependency Direction", "## Required Gates"),
    "DATABASE_AND_MIGRATION_GUIDELINES.md": ("## Test Isolation", "## Production Safety"),
    "PROVIDER_ADAPTER_GUIDELINES.md": ("## Provider Neutrality", "## Conformance"),
    "REVIEWER_SERVICE_GUIDELINES.md": ("## Separation of Duties", "## Attestations"),
    "WEB_UI_GUIDELINES.md": ("## Accessibility", "## Testing"),
    "SECRETS_AND_IDENTITY_GUIDELINES.md": ("## Storage", "## Identity Separation"),
    "UPSTREAM_AND_LINUX_INSTALL_GUIDELINES.md": ("## Upstream baseline", "## Linux installer ownership"),
}
REQUIRED_TEMPLATE_HEADINGS = (
    "## Applicability Summary",
    "## Code-Path-to-Test Mapping",
    "## Testability and Verification",
    "## Delegation Record",
    "## Independent Review Record",
    "## Upstream Patch Assessment",
    "## Rollback and Release Evidence",
)
REQUIRED_WORKSPACE = {
    "wshm-core",
    "idwp-domain",
    "idwp-application",
    "idwp-provider-contract",
    "idwp-review-contract",
    "idwp-architecture-tests",
}
FORBIDDEN_SECRET = re.compile(
    r"(?i)(?:gh[opsu]_[a-z0-9]{20,}|sk-[a-z0-9]{20,}|"
    r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|"
    r"(?:password|token|api_key|client_secret)\s*=\s*[\"'](?!REPLACE_|secret://)[^\"']+[\"'])"
)


def fail(message: str) -> None:
    raise ValueError(message)


def load_metadata() -> dict:
    result = subprocess.run(
        ["cargo", "metadata", "--locked", "--format-version", "1"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def validate_files() -> None:
    for relative in REQUIRED_FILES:
        path = ROOT / relative
        if not path.is_file() or path.stat().st_size == 0:
            fail(f"required nonempty file is missing: {relative}")
    guideline_root = ROOT / "Project Specific Guidelines"
    for filename, headings in REQUIRED_GUIDELINES.items():
        text = (guideline_root / filename).read_text(encoding="utf-8")
        for heading in headings:
            if heading not in text:
                fail(f"{filename} is missing required heading: {heading}")
    template = (ROOT / "docs/implementation_plans/templates/epic-template.md").read_text(
        encoding="utf-8"
    )
    for heading in REQUIRED_TEMPLATE_HEADINGS:
        if heading not in template:
            fail(f"implementation-plan template is missing: {heading}")


def validate_config() -> None:
    path = ROOT / "idwp/config/idwp.example.toml"
    text = path.read_text(encoding="utf-8")
    tomllib.loads(text)
    match = FORBIDDEN_SECRET.search(text)
    if match:
        fail(f"sanitized config contains a secret-like value: {match.group(0)[:24]}")
    for required in ("REPLACE_WITH_", "secret://", "example.invalid", "Unavailable"):
        if required not in text:
            fail(f"sanitized config is missing marker: {required}")


def components(metadata: dict) -> list[dict]:
    workspace_ids = set(metadata["workspace_members"])
    workspace_names = {
        package["name"] for package in metadata["packages"] if package["id"] in workspace_ids
    }
    if workspace_names != REQUIRED_WORKSPACE:
        fail(
            "workspace members differ: "
            f"expected {sorted(REQUIRED_WORKSPACE)}, got {sorted(workspace_names)}"
        )
    result = []
    for package in sorted(metadata["packages"], key=lambda item: (item["name"], item["version"])):
        is_workspace = package["id"] in workspace_ids
        license_value = package.get("license")
        license_file = package.get("license_file")
        if not is_workspace and not license_value and not license_file:
            fail(f"Rust dependency lacks license metadata: {package['name']} {package['version']}")
        component = {
            "type": "application" if package["name"] == "wshm-core" else "library",
            "name": package["name"],
            "version": package["version"],
            "purl": f"pkg:cargo/{package['name']}@{package['version']}",
        }
        if license_value:
            component["licenses"] = [{"expression": license_value}]
        elif license_file:
            component["licenses"] = [{"name": f"License file: {license_file}"}]
        result.append(component)
    package_lock = json.loads((ROOT / "web/package-lock.json").read_text(encoding="utf-8"))
    for path, package in sorted(package_lock.get("packages", {}).items()):
        if not path.startswith("node_modules/"):
            continue
        name = package.get("name") or path.removeprefix("node_modules/")
        version = package.get("version")
        license_value = package.get("license")
        if not version or not license_value:
            fail(f"frontend dependency lacks version/license metadata: {name}")
        result.append(
            {
                "type": "library",
                "name": name,
                "version": version,
                "purl": f"pkg:npm/{name}@{version}",
                "licenses": [{"expression": license_value}],
            }
        )
    return result


def write_sbom(path: pathlib.Path, items: list[dict]) -> None:
    document = {
        "bomFormat": "CycloneDX",
        "specVersion": "1.5",
        "version": 1,
        "metadata": {
            "component": {
                "type": "application",
                "name": "IndependentDeveloperWorkflowMCP",
            }
        },
        "components": items,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(document, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    parsed = json.loads(path.read_text(encoding="utf-8"))
    if parsed["bomFormat"] != "CycloneDX" or not parsed["components"]:
        fail("generated SBOM failed structural validation")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sbom", type=pathlib.Path, required=True)
    args = parser.parse_args()
    validate_files()
    validate_config()
    write_sbom(args.sbom, components(load_metadata()))
    print(f"Epic 3 asset checks passed; SBOM: {args.sbom}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.CalledProcessError, tomllib.TOMLDecodeError) as error:
        print(f"Epic 3 asset check failed: {error}", file=sys.stderr)
        sys.exit(1)

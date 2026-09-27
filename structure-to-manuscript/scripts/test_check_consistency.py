"""Test exact failure reasons and read-only behavior of the consistency guard."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("check_consistency.py")
SPEC = importlib.util.spec_from_file_location("check_consistency", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def digest(path: Path) -> str:
    """Return a content fingerprint for side-effect verification."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def ready_fixture(root: Path) -> tuple[Path, Path]:
    """Create the smallest valid two-chapter handoff and manuscript."""
    outline = {
        "schema_version": 1,
        "title": "검증 가능한 책",
        "reader": "긴 글의 구조가 필요한 사람",
        "problem": "구조와 집필이 섞인다",
        "promise": "구조와 집필을 분리해 원고를 완성한다",
        "glossary": [{"term": "구조 레이어", "forbidden_variants": ["구조레이어"]}],
        "chapters": [
            {
                "id": 1,
                "slug": "structure",
                "title": "구조",
                "goal": "구조를 고정한다",
                "key_claims": ["구조가 먼저다"],
                "depends_on": [],
            },
            {
                "id": 2,
                "slug": "manuscript",
                "title": "원고",
                "goal": "구조와 집필을 분리해 원고를 완성한다",
                "key_claims": ["원고는 구조를 구현한다"],
                "depends_on": [1],
                "resolves_promise": True,
            },
        ],
    }
    outline_path = root / "outline.json"
    outline_path.write_text(json.dumps(outline, ensure_ascii=False), encoding="utf-8")
    manuscript = root / "manuscript"
    manuscript.mkdir()
    (manuscript / "01_structure.md").write_text("구조 레이어를 고정한다.\n", encoding="utf-8")
    (manuscript / "02_manuscript.md").write_text("승인된 구조로 원고를 완성한다.\n", encoding="utf-8")
    return outline_path, manuscript


class ConsistencyTests(unittest.TestCase):
    """Protect the model-role handoff contract from silent drift."""

    def test_valid_contract_passes_without_changing_files(self) -> None:
        """Accept a valid handoff and preserve every input byte."""
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            outline, manuscript = ready_fixture(root)
            paths = [outline, *sorted(manuscript.glob("*.md"))]
            before = {path: digest(path) for path in paths}
            self.assertEqual(MODULE.validate(outline, manuscript, 0.25), [])
            self.assertEqual(before, {path: digest(path) for path in paths})

    def test_forward_dependency_fails_for_the_intended_reason(self) -> None:
        """Reject a forward dependency rather than accepting any generic failure."""
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            outline, manuscript = ready_fixture(root)
            data = json.loads(outline.read_text(encoding="utf-8"))
            data["chapters"][0]["depends_on"] = [2]
            outline.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            issues = MODULE.validate(outline, manuscript, 0.25)
        self.assertIn("FORWARD_DEPENDENCY: 1:2", issues)
        self.assertNotIn("INVALID_OUTLINE: JSONDecodeError", issues)

    def test_unresolved_todo_and_forbidden_term_are_separate(self) -> None:
        """Report unfinished evidence and terminology drift independently."""
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            outline, manuscript = ready_fixture(root)
            path = manuscript / "01_structure.md"
            path.write_text("구조레이어 [TODO: 근거]\n", encoding="utf-8")
            issues = MODULE.validate(outline, manuscript, 0.25)
        self.assertIn("FORBIDDEN_TERM: 01_structure.md:구조레이어:1:구조 레이어", issues)
        self.assertIn("UNRESOLVED_TODO: 01_structure.md:1", issues)

    def test_missing_promise_resolution_declaration_is_rejected(self) -> None:
        """Require an explicit final-chapter promise-resolution contract."""
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            outline, manuscript = ready_fixture(root)
            data = json.loads(outline.read_text(encoding="utf-8"))
            del data["chapters"][-1]["resolves_promise"]
            outline.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            issues = MODULE.validate(outline, manuscript, 0.25)
        self.assertIn("PROMISE_RESOLUTION_NOT_DECLARED", issues)

    def test_cli_reports_exact_missing_chapter_reason(self) -> None:
        """Exercise the public CLI and preserve its diagnostic contract."""
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            outline, manuscript = ready_fixture(root)
            (manuscript / "02_manuscript.md").unlink()
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(outline), str(manuscript)],
                capture_output=True,
                text=True,
                encoding="utf-8",
                check=False,
            )
        self.assertEqual(result.returncode, 1)
        self.assertIn("MISSING_CHAPTER_FILE: 02_manuscript.md", result.stderr)


if __name__ == "__main__":
    unittest.main()

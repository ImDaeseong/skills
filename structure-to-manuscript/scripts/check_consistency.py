#!/usr/bin/env python3
"""Check the deterministic contract between outline.json and chapter files."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


REQUIRED_TOP_LEVEL = (
    "schema_version",
    "title",
    "reader",
    "problem",
    "promise",
    "chapters",
)
REQUIRED_CHAPTER = ("id", "slug", "title", "goal", "key_claims", "depends_on")
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def count_words(text: str) -> int:
    """Approximate Korean eojeol and English word counts using whitespace."""
    return len(re.findall(r"\S+", text))


def validate(outline_path: Path, manuscript_dir: Path, tolerance: float) -> list[str]:
    """Return stable diagnostics without modifying the outline or manuscript."""
    try:
        outline = json.loads(outline_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"INVALID_OUTLINE: {type(exc).__name__}"]

    issues: list[str] = []
    for field in REQUIRED_TOP_LEVEL:
        if field not in outline:
            issues.append(f"MISSING_OUTLINE_FIELD: {field}")
    if issues:
        return issues
    if outline["schema_version"] != 1:
        issues.append(f"UNSUPPORTED_SCHEMA_VERSION: {outline['schema_version']}")

    chapters = outline["chapters"]
    if not isinstance(chapters, list) or not chapters:
        return [*issues, "EMPTY_CHAPTERS"]
    valid_chapters: list[dict] = []
    for index, chapter in enumerate(chapters, start=1):
        if not isinstance(chapter, dict):
            issues.append(f"INVALID_CHAPTER: {index}")
            continue
        missing = [field for field in REQUIRED_CHAPTER if field not in chapter]
        issues.extend(f"MISSING_CHAPTER_FIELD: {index}:{field}" for field in missing)
        if not missing:
            valid_chapters.append(chapter)
    if len(valid_chapters) != len(chapters):
        return issues

    ids = [chapter["id"] for chapter in chapters]
    expected_ids = list(range(1, len(chapters) + 1))
    if ids != expected_ids:
        issues.append(f"NON_CONTIGUOUS_IDS: {ids}")
    for chapter in chapters:
        chapter_id = chapter["id"]
        if not SLUG_PATTERN.fullmatch(str(chapter["slug"])):
            issues.append(f"INVALID_SLUG: {chapter_id}:{chapter['slug']}")
        for dependency in chapter["depends_on"]:
            if dependency not in ids:
                issues.append(f"UNKNOWN_DEPENDENCY: {chapter_id}:{dependency}")
            elif dependency >= chapter_id:
                issues.append(f"FORWARD_DEPENDENCY: {chapter_id}:{dependency}")

    if chapters[-1].get("resolves_promise") is not True:
        issues.append("PROMISE_RESOLUTION_NOT_DECLARED")

    expected_files = {
        f"{chapter['id']:02d}_{chapter['slug']}.md": chapter for chapter in chapters
    }
    present_files = {path.name for path in manuscript_dir.glob("*.md")}
    issues.extend(f"MISSING_CHAPTER_FILE: {name}" for name in sorted(set(expected_files) - present_files))
    issues.extend(f"EXTRA_CHAPTER_FILE: {name}" for name in sorted(present_files - set(expected_files)))

    glossary = outline.get("glossary", [])
    for name, chapter in expected_files.items():
        path = manuscript_dir / name
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        target = chapter.get("target_words")
        if isinstance(target, int) and target > 0:
            words = count_words(text)
            lower = int(target * (1 - tolerance))
            upper = int(target * (1 + tolerance))
            if not lower <= words <= upper:
                issues.append(f"WORD_COUNT_OUT_OF_RANGE: {name}:{words}:{lower}-{upper}")
        for term in glossary:
            for variant in term.get("forbidden_variants", []):
                occurrences = text.count(variant)
                if occurrences:
                    issues.append(
                        f"FORBIDDEN_TERM: {name}:{variant}:{occurrences}:{term['term']}"
                    )
        todos = re.findall(r"\[TODO[^\]]*\]", text)
        if todos:
            issues.append(f"UNRESOLVED_TODO: {name}:{len(todos)}")
    return issues


def main(argv: list[str] | None = None) -> int:
    """Run validation and print one deterministic result per line."""
    parser = argparse.ArgumentParser()
    parser.add_argument("outline", type=Path)
    parser.add_argument("manuscript_dir", type=Path)
    parser.add_argument("--tolerance", type=float, default=0.25)
    args = parser.parse_args(argv)
    if not 0 <= args.tolerance < 1:
        print("INVALID_TOLERANCE", file=sys.stderr)
        return 2
    issues = validate(args.outline, args.manuscript_dir, args.tolerance)
    if issues:
        print("\n".join(issues), file=sys.stderr)
        return 1
    print("PASS STRUCTURE_TO_MANUSCRIPT_CONSISTENCY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

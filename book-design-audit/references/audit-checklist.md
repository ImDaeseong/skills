# Visual audit checklist

Apply only the sections relevant to the requested artifact.

## PDF and print-oriented layout

- Confirm page count, page dimensions, orientation, metadata, and font embedding.
- Render every page at a resolution that exposes small text and image defects.
- Check safe margins, binding-side margin, folios, running heads, baseline rhythm, and consistent text blocks.
- Check body font size, leading, paragraph separation, indentation, alignment, emphasis, and link treatment.
- Check heading hierarchy, chapter/part openings, isolated headings, widows/orphans, and unintended blank pages.
- Check tables and code for clipping, wrapping, repeated headers where needed, contrast, and legible minimum text.
- Check figures for effective resolution, scaling, contrast, captions, source/rights labels, and proximity to their references.
- Check grayscale legibility when print may be monochrome.
- Keep printer marks, bleed, spine, and cover geometry as publisher decisions unless specifications are supplied.

## EPUB and reflow

- Confirm package metadata, language, title, author, navigation, reading order, landmarks, headings, links, and image alternatives.
- Inspect in a dedicated reader when available; identify the reader and version.
- Test default text, enlarged text, narrow viewport, light/dark themes when supported, and user font overrides.
- Check that text reflows without horizontal scrolling, clipping, overlap, or lost information.
- Check code, tables, callouts, figures, captions, and long URLs under reflow.
- Confirm that color is not the only carrier of meaning and that images of text are avoided unless essential.
- Do not require pixel-identical appearance across readers.

## Page-class coverage record

Record at least one inspected location for every class that exists: cover, front matter, contents, part opener, chapter opener, prose, list, table, code, figure, references, and final page. “Not present” is different from “not inspected.”

## Finding evidence

Each finding needs an observable location and a repair verification. A valid negative finding states why it failed; an unrelated renderer crash is `INVALID`, not proof of a layout defect.

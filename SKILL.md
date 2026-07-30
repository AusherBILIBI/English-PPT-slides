---
name: english-courseware-ppt
description: Create or revise classroom-ready English courseware PPTX decks from DOCX, PDF, or existing PPTX sources. Use for Chinese middle/high-school English teaching decks, reading-continuation writing, advanced sentence imitation, unit composition summaries, topic-writing guidance, sentence-pattern practice, expression training, answer-reveal practice, long multi-part decks, style-reference routing, gold PPT reuse, and full-deck verification.
---

# English Courseware PPT

## Purpose

Use this skill to create public-shareable, classroom-projection English courseware PPTX decks while preserving the production habits proven in prior gold decks.

Default to one skill with multiple style routes. Do not split into separate skills for reading continuation, unit composition, sentence practice, and topic-writing unless the user explicitly asks for separate installable skills.

## Start Here

1. Identify the task type: `reading-continuation`, `unit-composition`, `topic-writing`, `sentence-practice`, `answer-reveal`, `exam-paper-crossover`, or `revision`.
2. Identify the requested style from the prompt. If no style is specified, use `warm-study-space` for courseware and `plain-classroom` for exam-like projection decks.
3. Read `references/style-routing.md` before choosing gold assets.
4. Read the task-specific reference:
   - `references/courseware-rules.md` for composition, topic-writing, sentence imitation, phrase banks, model essays, and revisions.
   - `references/answer-reveal.md` for prompt-answer slides with click-to-reveal answers.
   - `references/long-deck-pipeline.md` for long reading-continuation decks or multi-part builds.
- `references/verification.md` before claiming completion.
- `references/gold-assets.md` when selecting or auditing bundled gold PPTX files.
- `references/public-release-checklist.md` before publishing or sharing a deck or this skill externally.
5. Treat the current user-supplied DOCX/PDF/PPTX as the wording authority. Gold PPTs are layout, density, style, animation, and verification references unless the user says a gold PPT is also the content source.
6. Build or revise the deck, export previews, inspect the rendered slides, and run relevant mechanical checks.

## Public Style Names

Use public names in prompts, filenames, and output notes:

- `warm-study-space`: warm orange classroom style with large title plates, cream/white cards, red answers, simple page furniture, and optional top-right course label. Use it for reading-continuation, unit-composition, sentence imitation, and answer-reveal decks.
- `clean-handout`: white, high-whitespace, image-and-text handout style with thin dividers and formal typography. Use it only when the prompt asks for this style, topic-writing guidance, or a clean handout look.
- `plain-classroom`: neutral white classroom style for cases where no branded/chrome-heavy style should be used.

Do not use private brand names in generated public decks. If a bundled gold PPT still contains private labels or logos, treat it as a reference to be reviewed or scrubbed before external release.

## Gold Asset Policy

Use bundled gold PPTs to reduce repeated layout mistakes. Open relevant gold decks before building, and borrow their layout rhythm directly when the task matches.

- Use `assets/gold/warm-study-space/` for unit-composition and warm orange courseware.
- Use `assets/gold/reading-continuation/` for long reading-continuation decks, sentence imitation, and multi-part deck structure.
- Use `assets/gold/answer-reveal/` for prompt-answer click reveal examples.
- Use `assets/gold/clean-handout/` for the alternate topic-writing guidance style.
- Use `assets/style-previews/` for quick visual routing when a full gold PPT audit is unnecessary.

Do not silently copy old wording from a gold deck into a new deck. When reusing a full slide as a template, replace content with the current source and remove private labels if the deliverable is intended for public sharing.

## Core Requirements

- Use `16:9` classroom-projection slides unless the user supplies a template with a different required size.
- Prefer editable text for courseware and ordinary text-heavy content.
- Use crops only for diagrams, framework maps, illustrated prompts, complex tables, special typography, or risky layout-critical regions.
- Keep classroom text readable: use `20 pt` or larger for body/question content wherever practical, and split instead of shrinking below readability.
- Keep complete teaching blocks together: prompt + clue + answer, phrase + meaning, model-essay paragraph, writing-framework region, or question + options.
- Preserve wording, numbering, punctuation, underlines, emphasis, blanks, colors that encode answers, and source order.
- For existing PPT revisions, fix the named slide and scan similar slides for the same repeated problem.
- For click-reveal decks, use simple `Fade / On Click` effects only; do not animate titles or already-visible prompts.
- Before public sharing, run a visual and package-text scrub for private labels, logos, student data, local paths, and copyrighted source material.

## Reusable Scripts

Use these when the task needs automation. Run each script with help before first use.

- `scripts/extract-docx-richtext.py`: extract DOCX paragraph/table order and run-level formatting into JSON.
- `scripts/apply-reveal-animations.ps1`: apply or refresh `Fade / On Click` animations for red answer shapes or `ans_*` shapes.
- `scripts/verify-ppt-qa.ps1`: compare final PPTX against QA reports, slide counts, source coverage, reveal counts, and animation reports.

Keep project-specific start/end markers, heading names, output filenames, and one-off arrays outside the skill. The skill stores reusable process and tools, not every historical build script.

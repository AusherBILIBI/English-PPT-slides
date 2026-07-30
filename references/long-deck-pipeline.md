# Long Deck Pipeline

Use this for long reading-continuation decks, multi-part sentence imitation, phrase-bank/corpus decks, or any source that is too large to build safely in one pass.

## Pipeline

1. Extract source truth from DOCX/PDF/PPTX into JSON.
2. Split the deck into natural teaching parts.
3. Build each part independently.
4. Export preview, layout, inspect, and source-coverage QA for each part.
5. Apply reveal animations only after answer shapes are stable.
6. Verify each part before merge.
7. Merge finished parts using PowerPoint-native slide insertion.
8. Verify total slide count and inspect all part boundaries.

## Reusable Tools

- `scripts/extract-docx-richtext.py`: preserve paragraph/table order, run-level formatting, red-answer lines, and normalized source lines.
- `scripts/apply-reveal-animations.ps1`: apply or refresh answer reveal animations.
- `scripts/verify-ppt-qa.ps1`: compare PPTX slide count, source coverage, reveal counts, animation reports, and optional layout counts.

Run help first:

```powershell
python scripts\extract-docx-richtext.py --help
powershell -ExecutionPolicy Bypass -File scripts\apply-reveal-animations.ps1 -Help
powershell -ExecutionPolicy Bypass -File scripts\verify-ppt-qa.ps1 -Help
```

## What Belongs In The Project

Keep task-local details outside the reusable skill:

- exact source headings and start/end markers;
- one-off data arrays;
- generated JSON, previews, layout files, and backups;
- output filenames;
- manual fixes for one existing deck.

For each multi-part project, create a task-local automation note or scripts folder that records source files, extraction commands, build commands, animation commands, QA locations, and final output locations.

## QA Contracts

- `source-coverage.json` should report zero missing source items before delivery.
- For answer-reveal decks, source red-answer count, generated reveal target count, and final animation report count must match.
- For corpus/display decks, `revealTargets=0` is valid only when recorded as expected.
- If the final PPTX changes after QA files were written, refresh the QA.
- After merging parts, final slide count must equal the sum of source parts unless a documented title/transition edit explains the difference.

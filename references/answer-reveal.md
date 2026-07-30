# Answer Reveal

Use this reference for sentence-practice, reading-continuation, expression-training, and bilingual prompt-answer decks where students see prompts first and click to reveal answers.

## Layout

- Use the style selected in `references/style-routing.md`.
- Keep Chinese prompts large, usually around `27-28 pt` in warm classroom cards.
- Keep English answers large, usually around `25 pt`; do not go below `20 pt`.
- Put prompts and answers on visually separate lines when the card has enough height.
- Put red English answers on or near the writing line when a writing line is present.
- Use 2-3 complete blocks per slide for medium items; use fewer for long prompts or answers.
- Fill the slide vertically; do not cluster all content in the center while leaving large unused top/bottom space.
- Remove optional helper subtitles and decorative badges unless requested.

## Content

- Student prompt sources provide visible prompts.
- Answer sources provide hidden or revealable answers.
- Preserve all question numbers and wording.
- Do not add teacher notes, explanations, or extra answers unless requested.
- If an answer source is incomplete, report the gap before inventing or translating missing answers.

## Animation

- Make each answer a separate editable text box.
- Prefer answer shape names like `ans_001`, `ans_002`, etc.
- Use only simple `Fade / On Click` entrance effects.
- Reveal order follows source question order.
- Do not animate page titles, section headers, number badges, visible prompts, or decorative shapes.
- After generation or XML edits, inspect PowerPoint animation order or animation XML.

## Scripted Animation

Use `scripts/apply-reveal-animations.ps1` when PowerPoint is available and answer targets are stable:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\apply-reveal-animations.ps1 `
  -Pptx path\to\deck.pptx `
  -Report path\to\qa\animation-report.json
```

The script targets shapes named `ans_*` or red-text answer shapes below a configurable top threshold. It creates a backup, removes stale target animations, sorts targets by slide/top/left, applies `Fade / On Click`, and writes a JSON report.

## QA

- Source answer count, generated answer-shape count, and final animation-report count should match.
- Every intended answer should have exactly one reveal effect.
- Zero reveal targets is valid only for corpus/display decks where no answer reveal is intended and the QA explicitly records that expectation.
- Render early, middle, and final slides at full size to check spacing and order.

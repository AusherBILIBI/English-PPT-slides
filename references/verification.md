# Verification

Use this before claiming an English courseware PPTX is complete.

## Mechanical Checks

- Confirm the final PPTX opens in PowerPoint.
- Export all slides to PNG previews when PowerPoint is available.
- Create or inspect a contact sheet for the full deck.
- For scripted builds, run relevant QA reports:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify-ppt-qa.ps1 `
  -Pptx path\to\final.pptx `
  -QaDir path\to\qa
```

Use `-AllowZeroReveal` only for corpus/display decks where no answer reveal is expected.

## Visual Review

Inspect rendered slides at full size, not only thumbnails.

- No text overlaps, clips, crosses card edges, or sits under page furniture.
- No content is hidden by page numbers, labels, images, or decorative shapes.
- Text is readable for classroom projection.
- Sparse slides use available space; crowded slides are split.
- Page numbers, number badges, and section titles are aligned.
- Gold-style visual rhythm is followed when a gold reference was selected.
- Public decks contain no unwanted private logos, company names, or hidden personal information.

## Source Review

- Current source content is complete, ordered, and not silently rewritten.
- No old-deck wording leaked into a new source-based deck.
- Question numbers are continuous when the source is numbered.
- Complete blocks stay together.
- Model essays are not cut mid-sentence.
- Phrase rows and bilingual pairs are not separated.
- For answer-reveal decks, every intended answer has exactly one reveal effect in source order.

## Revision Review

- The named slide issue is fixed.
- Similar slides were scanned for the same repeated issue.
- Late edits were followed by refreshed previews and QA.
- If any verification step could not be run, state that explicitly in the final handoff.

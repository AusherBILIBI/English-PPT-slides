# Courseware Rules

## Source Truth

- Treat the current DOCX/PDF/PPTX as the source of wording.
- Use gold PPTs as style, density, layout, and animation references only.
- Do not copy old deck text unless the user says the old PPT is the source.
- Restore complete sentences from extraction output before layout; do not preserve broken Word/PDF line breaks mechanically.
- Never split a word, phrase, prompt, answer, or option group across text boxes due to extraction artifacts.

## Layout Routing

Classify each teaching section before slide creation:

- `editable-text`: ordinary courseware text, phrase banks, sentence imitation, model essays, writing guidance, and text-heavy classroom content.
- `screenshot-crop`: diagrams, mind maps, visual writing frameworks, tables, illustrated prompts, or special typography where rebuilding risks errors.
- `hybrid`: editable text plus a cropped visual object.

Do not map one source page mechanically to one slide. Split by teaching rhythm, semantic unit, natural paragraph, complete question, or classroom readability.

## Density

- Do not default to one item per slide.
- Merge short complete blocks when a slide would otherwise look sparse.
- Do not force a fixed number of items per slide.
- If one slide is crowded at readable size, move a complete block to the next slide instead of shrinking.
- If a slide is sparse, use the available space through larger text, better vertical fill, or combining related blocks.
- Keep body/question text at `20 pt` or larger wherever practical.
- Keep ordinary model-essay body text around `21 pt` or larger where practical.

## Common Courseware Sections

Include only sections present in the source or requested by the user:

- review and topic introduction;
- writing task and review guidance;
- writing framework;
- opening/body/ending paragraph patterns;
- phrase and expression accumulation;
- advanced sentence patterns;
- sentence imitation practice;
- topic quotes or theme language;
- model essay;
- self-check checklist.

## Phrase And Expression Slides

- Use clear English-Chinese pairing.
- For dense phrase lists, use two columns or card grids with one logical row per pair.
- Keep row spacing large enough that pairs are obvious.
- Move bullets or numbering with the text row; do not leave markers at old positions after reflow.
- If reveal is requested and the source is English-first, keep English visible and reveal the Chinese meaning.
- If reveal is prompt-first, keep the prompt visible and reveal only the answer.

## Sentence Practice And Imitation

- Keep each complete block together: number, Chinese prompt, English clue/formula, target answer, and any pattern label.
- Short items may share a slide; medium items often fit 2-3 per slide; long items may stand alone.
- Keep prompt and answer on the same slide unless a long block is intentionally split for teaching.
- Do not animate section titles, title bars, page headers, or already-visible prompts.
- Preserve red text as an answer signal when source red text marks answers.

## Model Essay Slides

- Use editable text for ordinary model essays.
- Keep an ordinary-length essay together when readable.
- Treat repeated headers, small labels, and decorative tags as optional if they reduce essay readability.
- Split only by complete natural paragraph.
- Do not cut a sentence across slides.

## Writing Framework And Mind Maps

- Crop or rebuild only the actual framework region.
- Preserve structure boxes, connector lines, theme boxes, labels, and source wording.
- Remove unrelated notes, vocabulary lists, headers, footers, watermarks, and neighboring fragments.
- Use a clean white strip to cover tiny edge noise rather than rewriting a diagram when the crop is otherwise correct.

## Revision Work

- Render or inspect the full deck before editing.
- Fix the annotated slides.
- Scan similar slides for the same issue.
- Re-render and inspect the revised deck.
- Verify source completeness, slide order, readability, overflow, and animation order before handoff.

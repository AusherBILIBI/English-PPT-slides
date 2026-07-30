# English Courseware PPT Skill

A public, reusable Codex skill for creating classroom-ready English courseware PowerPoint decks from DOCX, PDF, or existing PPTX sources.

This skill packages the workflow, rules, scripts, style previews, and gold PPTX references used for Chinese middle/high-school English courseware production.

## What It Does

- Builds or revises English classroom PPTX decks.
- Supports reading-continuation writing, unit composition, topic-writing guidance, sentence imitation, sentence-pattern practice, expression training, and answer-reveal practice.
- Reuses bundled gold decks as layout and verification references so future builds stay stable and token-efficient.
- Routes between multiple public style names instead of requiring separate skills for each courseware type.

## Install

Clone or download this repository, then place the whole folder in your Codex skills directory:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse ".\english-courseware-ppt" "$env:USERPROFILE\.codex\skills\english-courseware-ppt"
```

If you are already inside this repository folder, use:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse "." "$env:USERPROFILE\.codex\skills\english-courseware-ppt"
```

On macOS or Linux:

```bash
mkdir -p ~/.codex/skills
cp -R ./english-courseware-ppt ~/.codex/skills/english-courseware-ppt
```

Restart Codex or start a new thread if the skill list does not refresh immediately.

## Basic Usage

Use one of these prompt shapes:

```text
Use $english-courseware-ppt to create a classroom-ready English courseware PPT from this DOCX.
```

```text
Use $english-courseware-ppt with the warm-study-space style to make a reading-continuation writing deck.
```

```text
Use $english-courseware-ppt with the clean-handout style to make a topic-writing guidance deck.
```

```text
Use $english-courseware-ppt to revise this PPTX. Keep the current wording, fix layout overflow, and preserve click-reveal answers.
```

## Style Routes

`warm-study-space` is the default warm orange classroom courseware style. Use it for reading-continuation, unit composition, sentence imitation, phrase cards, and answer-reveal decks.

`clean-handout` is the alternate clean topic-writing / handout style. Use it only when requested.

`plain-classroom` is a neutral white classroom style for exam-like projection decks or when no decorative courseware chrome is wanted.

Preview images are in `assets/style-previews/`.

## Gold Assets

Gold PPTX files live in `assets/gold/` and are intended as reference assets:

- `warm-study-space/`
- `reading-continuation/`
- `answer-reveal/`
- `clean-handout/`

Open the matching gold deck before building. Borrow layout rhythm, density, color roles, animation behavior, and verification habits. Do not silently copy old teaching wording into a new deck unless the user explicitly says the gold PPT is also the content source.

## Public Release Safety

Before publishing a generated deck or redistributing this skill package, review:

- `references/public-release-checklist.md`
- `references/gold-assets.md`
- `LICENSE-INFO.md`

The bundled PPTX files may contain historical teaching examples, textbook-derived language, or other content that needs a human copyright/privacy review before broad redistribution.

## Maintenance

Useful scripts:

```powershell
python .\scripts\extract-docx-richtext.py --help
powershell -ExecutionPolicy Bypass -File .\scripts\apply-reveal-animations.ps1 -Help
powershell -ExecutionPolicy Bypass -File .\scripts\verify-ppt-qa.ps1 -Help
powershell -ExecutionPolicy Bypass -File .\scripts\scrub-pptx-metadata.ps1 -Root . -ReportOnly
```

Fast package text scan example:

```powershell
rg -n "PRIVATE_BRAND_NAME|LOCAL_PATH_FRAGMENT|STUDENT_NAME" .
```

The visual logo/text check still needs rendered slide previews; package text scans cannot detect flattened text inside images.

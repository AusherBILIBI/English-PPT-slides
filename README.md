# English Courseware PPT Skill

A public, reusable Codex skill for creating classroom-ready English courseware PowerPoint decks from DOCX, PDF, or existing PPTX sources.

This is not just a PowerPoint template. It packages a practical English-teaching PPT production workflow: gold reference decks, style previews, answer-reveal animation rules, DOCX extraction scripts, QA checks, and agent routing notes that help Codex create more consistent classroom slides with less repeated prompting.

中文简介：

English Courseware PPT Skill 是一个面向英语老师和教研人员的 Codex skill，可以帮助你把 Word、PDF、旧 PPT 等资料快速整理成适合课堂展示的英文课件。它内置了可参考的 gold PPT、课件风格预览、答案揭示动画规则、质检脚本和 `agents/` 配置，让 Codex 更稳定地理解课件制作流程，而不只是套用一个普通 PPT 模板。

Download the latest release package here:

https://github.com/AusherBILIBI/English-PPT-slides/releases/latest

## Best For

- English composition lessons.
- Reading-continuation writing.
- Unit writing guidance.
- Topic-writing guidance.
- Sentence imitation and sentence-pattern practice.
- Expression training.
- Answer-reveal classroom activities.

## Why Use It

- It gives Codex a reusable courseware workflow, not only a visual theme.
- It includes bundled gold PPTX decks so future builds can follow proven layout rhythm, density, and classroom readability.
- It supports multiple public style routes in one installable skill instead of requiring a separate skill for every lesson type.
- It includes `agents/` configuration to help assistants understand the intended workflow, style choices, bundled assets, and verification steps more consistently.
- It is distributed through versioned GitHub Releases, so teachers and courseware creators can download a stable zip package and update later.

## What It Does

- Builds or revises English classroom PPTX decks.
- Supports reading-continuation writing, unit composition, topic-writing guidance, sentence imitation, sentence-pattern practice, expression training, and answer-reveal practice.
- Reuses bundled gold decks as layout and verification references so future builds stay stable and token-efficient.
- Routes between multiple public style names instead of requiring separate skills for each courseware type.

## Agent Support

This skill includes an `agents/` configuration for Codex/OpenAI-style agent routing. It helps future assistants understand when to inspect gold decks, how to choose a public style route, which bundled scripts are available, and what verification steps should happen before a PPTX is considered ready.

## Install

The easiest option is to download the latest release package from:

https://github.com/AusherBILIBI/English-PPT-slides/releases

Download `english-courseware-ppt-vX.Y.Z.zip`, extract it, then place the extracted `english-courseware-ppt` folder in your Codex skills directory.

On Windows:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse ".\english-courseware-ppt" "$env:USERPROFILE\.codex\skills\english-courseware-ppt" -Force
```

If you cloned the repository instead of downloading a release package, run this from inside the repository root:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse "." "$env:USERPROFILE\.codex\skills\english-courseware-ppt" -Force
```

On macOS or Linux:

```bash
mkdir -p ~/.codex/skills
cp -R ./english-courseware-ppt ~/.codex/skills/english-courseware-ppt
```

Restart Codex or start a new thread if the skill list does not refresh immediately.

## Versioned Releases

This package uses semantic versions:

- Patch releases, such as `v0.1.1`, are small fixes to docs, scripts, or scrubbed assets.
- Minor releases, such as `v0.2.0`, add a new style route, workflow, or bundled gold asset family.
- Major releases, such as `v1.0.0`, may change skill behavior or public prompt conventions.

Release packages are built with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-release.ps1
```

Upload the generated `english-courseware-ppt-vX.Y.Z.zip` to the matching GitHub Release.

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

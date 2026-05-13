**A notes-like daily journal app that autosaves locally, generates an editable AI summary, and pushes the final Markdown to GitHub.**

---

# Open DevLog — V1 MVP Spec

## Platforms

```txt
Flutter app should support:
- Desktop
- Android
- Web
```

But keep one thing in mind:

```txt
Desktop + Android = better local file/database support
Web = more limited local storage
```

ignore web for now

---

# Core V1 Flow

```txt
First open
↓
Connect GitHub
↓
Add AI API key
↓
Select or create GitHub repo
↓
Go to Home
↓
Blank slate journal editor
↓
Autosave locally while typing
↓
Generate AI summary
↓
Edit AI summary manually
↓
Push final Markdown to GitHub
```

That’s it.

No complicated dashboard yet.

---

# App Screens For V1

## 1. First-Time Setup Screen

Shown only when app opens for the first time.

Steps:

```txt
Step 1: Connect GitHub
Step 2: Add AI API key
Step 3: Select or create repo
Step 4: Start journaling
```

### GitHub Setup

User should be able to:

```txt
Paste GitHub Personal Access Token
Fetch repos
Select existing repo
OR create new repo
```

Default repo suggestion:

```txt
Dev Journal
```

### AI Setup

User should be able to add:

```txt
AI provider
API key
Model name
```

For V1, keep it simple:

```txt
Provider: Gemini / OpenAI / Groq
API Key: user enters manually
```

Store API key locally.

Later you can improve security.

---

## 2. Home Screen — Main Feature

This should be the heart of the app.

Not dashboard.
Not cards everywhere.
Not analytics first.

Just a **beautiful blank slate**.

Layout:

```txt
Top bar:
May 13, 2026              Saved locally 5 sec ago

Main:
Large blank editor

Bottom / side actions:
Generate Summary
Preview Final Markdown
Push to GitHub
Previous Entries
Settings
```

The home screen should feel like:

```txt
Apple Notes + Obsidian + GitHub devlog
```

Minimal. Calm. Clean.

---

# Home Screen Priority

The editor is the product.

Everything else should feel secondary.

Good UI feeling:

```txt
The user opens app and immediately starts writing.
```

Bad UI feeling:

```txt
The user opens app and sees 10 cards, charts, buttons, analytics, and distractions.
```

So should build:

```txt
Large text editor
Autosave status
Date selector
Simple actions
```

---

# Autosave Requirement

This is still the most important technical feature.

## Autosave should happen:

```txt
- While typing
- After short pause
- Every few seconds if text changed
- When app goes to background
- Before AI summary generation
- Before GitHub push
- Before changing selected date
```

## UI should show:

```txt
Saving...
Saved locally 3 sec ago
Local save failed
Unsaved changes
```

Example status:

```txt
● Saved locally 8 seconds ago
```

Do not overcomplicate it.

---

# Journal Entry Format

Each day has one journal entry.

Fields:

```txt
date
roughDiary
aiSummary
finalMarkdown
lastSavedAt
lastCommittedAt
githubCommitSha
isCommitted
```

For V1, that’s enough.

---

# Daily Markdown File Format

When pushed to GitHub, each file should include:

```md
# Daily DevLog — May 13, 2026

## AI Summary

...

## Time Allocation

...

## Wins

...

## Wasted Time / Distractions

...

## Improvements For Tomorrow

...

## Tags

...

---

## Rough Diary

...
```

Important: you said you will manually remove personal stuff before generating/pushing.

So the app does not need advanced privacy filtering in V1.

But the AI prompt can still say:

```txt
Do not expose highly personal/private details.
```

---

# GitHub File Structure

Use this:

```txt
open-devlog/
│
├── 2026/
│   ├── May/
│   │   ├── 01-05-2026.md
│   │   ├── 02-05-2026.md
│   │   └── 03-05-2026.md
│   │
│   └── yearly-summary.md
│
└── README.md
```

For V1, only daily files are needed.

Monthly summary can come later.

---

# AI Summary Flow

The flow should be:

```txt
User writes rough diary
↓
User manually removes personal/private stuff if needed
↓
Clicks Generate Summary
↓
AI creates summary + analytics
↓
Generated output is shown in editable editor
↓
User edits summary
↓
User clicks Push to GitHub
```

Very important:

> AI output should never be directly pushed without showing editable preview first.

---

# AI Summary Screen

This can be simple.

```txt
Left / top:
Rough Diary

Right / bottom:
Generated Summary Editable Area
```

Buttons:

```txt
Regenerate
Save Summary
Preview Markdown
Push to GitHub
```

For desktop:

```txt
Split view
```

For mobile:

```txt
Tabs:
Raw Diary | AI Summary | Final Markdown
```

---

# Charts In Markdown

For V1, don’t build complicated in-app charts.

Inside Markdown, you can use simple text tables first.

Example:

```md
## Time Allocation

| Category | Time |
|---|---:|
| Coding | 3h |
| DSA | 1h |
| Club Work | 2h |
| Wasted Time | 1h |
```

Later, you can add Mermaid charts:

````md
```mermaid
pie title Time Allocation
  "Coding" : 3
  "DSA" : 1
  "Club Work" : 2
  "Wasted Time" : 1
````

````

For GitHub, Mermaid diagrams render well in Markdown, so this is better than SVG for V1.

---

# Auto Commit Feature

Settings should have:

```txt
Auto commit enabled: true/false
Commit time: 11:30 PM default
````

Behavior:

```txt
If today's entry is not committed by 11:30 PM:
- Generate final Markdown from latest saved rough diary + saved AI summary
- Commit to GitHub automatically
```

But for V1, I would make this safer:

```txt
Auto commit only commits if AI summary already exists.
```

Because you said you want to manually remove personal stuff before summary.

So don’t let the app auto-generate and auto-push raw private content accidentally.

Better V1 behavior:

```txt
At 11:30 PM:
If final markdown is ready but not pushed:
    auto commit
Else:
    show reminder / pending status
```

For privacy, this is safer.

---

# Previous Entries

Simple screen:

```txt
Previous Entries
May 13, 2026 — Not committed
May 12, 2026 — Committed
May 11, 2026 — Committed
```

Clicking a day opens that day’s editor.

Previous entries should be editable.

If user edits an already committed day:

```txt
Status changes to: Modified after commit
Button: Push update to GitHub
```

---

# Streak

Add simple streak in top bar or previous entries screen.

```txt
Current streak: 7 days
```

Streak rule:

```txt
A day counts if rough diary is not empty.
```

Not if committed.
Not if AI summary exists.

Just writing should count.

---

# V1 Navigation

Keep it small:

```txt
Home
Entries
Settings
```

Maybe add:

```txt
Summary Preview
```

but it can be opened from Home.

Do not create separate Insights/Dashboard screen yet.

---

# Recommended V1 UI Style

```txt
Minimal notes app
Dark mode first
Large editor
Beautiful typography
Very little clutter
Soft borders
Subtle GitHub/dev feel
```

Avoid:

```txt
Too many charts
Too many cards
Too much neon
Too much AI dashboard feeling
```

The app should feel like:

```txt
“Open it and write.”
```

---

# Master Prompt

Use this with Codex:

```txt
I want to build a Flutter app called Open DevLog.

Open DevLog is a cross-platform daily developer journal app for desktop, Android, and web.

The V1 MVP should be simple and reliable:
The user opens the app, writes a rough daily diary in a blank notes-like editor, the app autosaves locally so data is never lost, then the user can generate an editable AI summary and push the final Markdown file to GitHub.

Build the app with Flutter.

Core requirements:

1. Platforms
- Support desktop, Android, and web.
- Use responsive UI.
- Desktop can use a sidebar layout.
- Mobile can use bottom navigation or simple top navigation.
- Web should work as much as possible using browser-supported local storage/database.

2. First-Time Setup Flow
When the app is opened for the first time, show setup screens:
- Connect GitHub by entering a GitHub Personal Access Token.
- Enter AI provider details/API key.
- Select an existing GitHub repo or create a new repo.
- Default suggested repo name: open-devlog.
- After setup, navigate to Home.

Store setup/config locally.

3. Home Screen
The Home screen is the main feature.
It should feel like a blank notes app.

Home screen should include:
- Current date at top.
- Autosave status indicator showing saved locally time.
- Large distraction-free text editor for rough diary.
- Buttons:
  - Generate AI Summary
  - Preview Final Markdown
  - Push to GitHub
  - Previous Entries
  - Settings
- The editor should load today’s saved diary automatically.
- The editor should autosave while typing.

4. Local Autosave
This is the most important feature.

Implement reliable local autosave:
- Save after the user stops typing for around 700ms.
- Save periodically every 5 seconds if text changed.
- Save when app goes inactive/background.
- Save before generating AI summary.
- Save before pushing to GitHub.
- Save before switching date/entry.
- Show status:
  - Saving...
  - Saved locally X seconds ago
  - Unsaved changes
  - Save failed

Use a clean architecture where autosave logic is not directly mixed into UI widgets.

5. Local Data Model
Each journal entry should have:
- id
- date
- roughDiary
- aiSummary
- finalMarkdown
- lastSavedAt
- lastCommittedAt
- githubCommitSha
- isCommitted
- createdAt
- updatedAt

Also store app settings:
- githubToken
- githubUsername
- selectedRepo
- selectedBranch
- aiProvider
- aiApiKey
- aiModel
- autoCommitEnabled
- autoCommitTime, default 23:30

6. Local Storage
Use a reliable local persistence approach that works across Flutter desktop, Android, and web.
Prefer SQLite/Drift if feasible across platforms.
If web support needs a different implementation, abstract storage behind repositories so the app code remains clean.

Repository methods needed:
- getEntryByDate(date)
- saveEntry(entry)
- updateRoughDiary(date, text)
- updateAiSummary(date, text)
- updateFinalMarkdown(date, markdown)
- listEntries()
- getSettings()
- saveSettings(settings)

7. Previous Entries Screen
Create a screen listing previous journal entries.
Each row should show:
- Date
- One-line preview from rough diary or AI summary
- Status: Committed / Not committed / Modified after commit
- Last saved time

Clicking an entry should open that day’s editor.
Previous entries should be editable.
If an already committed entry is edited, mark it as modified after commit.

8. AI Summary Generation
The user clicks Generate AI Summary after writing the rough diary.

Before generating:
- Force autosave the latest rough diary.

Then call the configured AI provider API.

Generate an editable AI summary with this structure:
- One-Line Summary
- Detailed Summary
- Timeline
- Time Allocation
- Wins
- Wasted Time / Distractions
- Improvements For Tomorrow
- Tags
- Optional Mermaid chart for time allocation

Show the generated summary in an editable text area.
Do not push directly to GitHub without user review.

Buttons:
- Save Summary
- Regenerate
- Preview Final Markdown
- Push to GitHub

9. Final Markdown Format
When previewing or pushing, generate final Markdown in this format:

# Daily DevLog — <Readable Date>

## AI Summary

<editable AI summary>

---

## Rough Diary

<rough diary text>

The rough diary should be included at the end.

10. GitHub Sync
Implement GitHub sync using GitHub REST API.

Features:
- Create repo if user chooses.
- Push daily Markdown file.
- File path format:
  YYYY/MM-Month/DD-MM-YYYY.md
Example:
  2026/05-May/13-05-2026.md

Commit message:
  Add devlog for DD-MM-YYYY
or if updating:
  Update devlog for DD-MM-YYYY

After successful push:
- Store commit SHA.
- Mark entry as committed.
- Store lastCommittedAt.

If push fails:
- Keep local data safe.
- Show error.
- Do not delete local content.

11. Auto Commit Setting
Settings screen should include:
- Auto commit toggle
- Commit time picker
- Default time: 11:30 PM

For V1 safety:
Auto commit should only push if finalMarkdown or aiSummary already exists.
Do not automatically generate AI summary and push raw private diary without user review.

If auto commit time is reached and today is not committed:
- If AI summary/final markdown exists, push to GitHub.
- Otherwise show status/reminder that summary is missing.

12. Settings Screen
Settings should include:
- GitHub token
- Selected repo
- Branch
- AI provider
- AI API key
- AI model
- Auto commit toggle
- Auto commit time
- Theme option
- Export local data option if easy

13. Streak
Add a simple writing streak.
A day counts toward streak if roughDiary is not empty.
Show streak somewhere subtle on Home or Previous Entries.

14. UI Style
Make the UI clean and beautiful but not overcomplicated.
It should feel like a premium notes app for developers.

Style:
- Dark mode first
- Large blank editor
- Minimal clutter
- Soft rounded cards
- Clean typography
- Subtle GitHub/dev-inspired details
- Autosave indicator should be visible and reassuring

Do not make it a heavy dashboard.
Do not add unnecessary analytics screens in V1.
The blank journal editor is the main product.

15. Code Quality
Use clean folder structure.
Separate:
- UI
- state management
- repositories
- services
- models

Use Riverpod or another clean state management approach.
Avoid putting API and storage logic inside widgets.
Write code that is easy to extend later.

V1 screens:
- Setup screen
- Home journal screen
- AI summary/edit screen
- Final Markdown preview screen
- Previous entries screen
- Settings screen

Do not build extra screens beyond this unless required.
```

---

# Even Better: Give This Development Order

After the master prompt, tell to implement in this order:

```txt
Implement in milestones.

Milestone 1:
Project setup, routing, theme, basic screens with mock data.

Milestone 2:
Local data models, repository, settings storage, journal entry persistence.

Milestone 3:
Home screen editor connected to real local autosave.

Milestone 4:
Previous entries screen with editable old entries.

Milestone 5:
AI summary generation and editable summary screen.

Milestone 6:
Final Markdown preview.

Milestone 7:
GitHub setup, repo select/create, push markdown.

Milestone 8:
Auto commit setting and scheduled check.

Do not jump ahead.
After each milestone, keep the app runnable.
```

This matters because ai may try to build everything at once and break half of it.

---

# Important V1 Safety Decision

For auto commit, I strongly recommend this rule:

```txt
Auto commit should NOT push raw diary unless user has already generated/reviewed the AI summary.
```

Because your rough diary might include private lines.

So auto commit should mean:

```txt
Auto-push already prepared final Markdown.
```

Not:

```txt
Take whatever I wrote and publish it automatically.
```

This protects you.

---

# Final V1 Feature List

Your launch MVP is:

```txt
✅ Flutter desktop/mobile/web
✅ First-time GitHub + AI setup
✅ Blank slate daily editor
✅ Local autosave
✅ Saved locally status
✅ Previous entries
✅ Editable old entries
✅ Generate AI summary
✅ Editable AI summary
✅ Final Markdown preview
✅ Push to GitHub
✅ Rough diary included at bottom
✅ Auto commit setting
✅ Basic streak
```

That is enough.

Don’t add monthly dashboard yet.
Don’t add charts dashboard yet.
Don’t add version history yet unless autosave is done perfectly.

For V1, the app should be known for one thing:

> **I can write my day freely, never lose it, and publish a clean devlog when I’m ready.**

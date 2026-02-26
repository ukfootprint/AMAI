# Browser Sync Strategy

## The problem

In browser-based AI sessions (Claude.ai, ChatGPT, Gemini), AMAI files are snapshots. The AI works from whatever you uploaded at upload time. It cannot detect that a file has changed since then. If you uploaded current_focus.yaml two weeks ago, the AI is working from a two-week-old version of your priorities. It will not flag this. You have to manage it.

## The sync set

Not all files change at the same frequency. The following files change most often and are therefore most likely to be stale in a browser session. Check and re-upload these specifically:

- goals/current_focus.yaml — changes weekly
- goals/goals.yaml — changes monthly or when goals shift
- signals/observations.jsonl — changes after any notable session
- calibration/metrics.jsonl — changes after each calibration

The following files change rarely and can be re-uploaded quarterly or when you deliberately update them:

- identity/values.yaml
- identity/voice.md
- identity/heuristics.yaml
- knowledge/frameworks.md
- BRAIN.md
- MODULE_SELECTION.md

## The pre-session ritual for browser use

Before starting a session in a browser-based AI, take 60 seconds to check:

1. When did I last upload current_focus.yaml to this project? If more than 7 days ago, re-upload it.
2. Have I run a calibration cycle since my last upload of goals.yaml? If yes, re-upload it.
3. Have I logged any signals since my last upload of observations.jsonl? If yes, re-upload it.

This is the minimum. Everything else can wait for the quarterly refresh.

## For Claude Projects specifically

Claude Projects persist uploaded files across conversations. This is convenient but creates a false sense of currency. A file uploaded three weeks ago is still there and still looks authoritative. The AI has no way to know it is out of date.

Add a note in your Project description that reads: "Sync set last updated: [DATE]". Update this each time you re-upload sync set files. It takes five seconds and gives you a visible staleness indicator without opening the files.

## For manual upload sessions (no Projects)

If you are uploading files at the start of each session, upload only the default minimal set plus any sync set files that have changed since your last session. Do not upload the full AMAI folder — token budget is limited and loading stale files you did not intend to use is worse than not loading them.

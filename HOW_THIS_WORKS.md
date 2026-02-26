# How AMAI Actually Works

## The mechanism

AMAI is a human-audited system, not a self-enforcing one.

When you start a session, the AI reads BRAIN.md and MODULE_SELECTION.md, loads the modules it judges to be relevant, and confirms what it loaded. You read that confirmation. If something is missing or wrong, you correct it before proceeding.

Nothing enforces correct loading automatically. The session-start confirmation is a visible audit hook — it creates an artefact you can check. Checking it is your job.

## What this means in practice

- The AI may say it loaded a module when it loaded it only partially, or summarised it rather than reading it in full. The confirmation is a good-faith report, not a guarantee.
- In browser sessions, files are snapshots. If you uploaded context two weeks ago, the AI is working from a two-week-old version of you. The AI cannot know this. You have to know it.
- If the AI's output feels misaligned — wrong voice, wrong priorities, ignoring a constraint — the most likely cause is a missing or stale module, not a model failure. Check the loaded module list first.

## What AMAI does not do

- It does not prevent the AI from ignoring instructions under pressure from a persuasive prompt.
- It does not verify that your declared values match your observed behaviour (that is what signals/ and calibration/ are for, over time).
- It does not enforce the don't-load list. It instructs the AI to follow it. There is a difference.

## What AMAI does do

- It gives every session a structured starting point that would otherwise take 10–15 minutes to reconstruct from scratch.
- It makes your context auditable: you can see what was loaded, check whether it is current, and correct it.
- It accumulates a record of your decisions, signals, and calibrations that gets more useful over time.

## The right mental model

Think of AMAI as a well-organised briefing pack, not a control system. A good briefing pack doesn't run the meeting — it means the meeting starts from a better place. You still run the meeting.

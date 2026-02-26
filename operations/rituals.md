# Rituals
*Your recurring commitments to yourself. These are the practices that keep you grounded, focused, and performing well.*

---

## Why Rituals Matter

No one manages your time but you. Rituals create the structure that prevents drift — they are the operating system beneath the operating system.

---

## Daily Rituals

### Morning (before reactive work)
- [ ] [Fill in: e.g. "20 minutes reading before opening email"]
- [ ] [Fill in: e.g. "Write down the one thing that matters today"]
- [ ] [Fill in: e.g. "5-minute review of current_focus.yaml"]

### End of Day
- [ ] [Fill in: e.g. "Close all browser tabs and write 3 lines: what I did, what blocked me, what tomorrow's priority is"]

---

## Weekly Rituals

### Weekly Review *(see operations/workflows.md for full process)*
- **When:** [Day, time]
- **Duration:** 30–45 minutes
- **Non-negotiable:** Yes

### Deep Work Block
- **When:** [Day, time]
- **Duration:** [X hours]
- **Rules:** No email, no calls, no context-switching

### Relationship Maintenance
- **When:** [Day, time — e.g. "Friday morning"]
- **Duration:** 20 minutes
- **What:** One personal message to someone in your network — not asking for anything, just maintaining contact

---

## Monthly Rituals

### Monthly Review *(see operations/workflows.md for full process)*
- **When:** Last working day of the month
- **Duration:** 60–90 minutes

### Calibration Review *(advanced layer — see calibration/MODULE.md)*
- **When:** During or immediately after monthly review
- **Duration:** 20–30 minutes
- **Files:** `calibration/pending_review.md`, `calibration/divergence.jsonl`, `calibration/metrics.yaml`
- **What:** Review all CANDIDATE and WARNING items. Disposition each one: INCORPORATE, REJECT, or continue DEFER. If incorporating, update the relevant config file and log the decision in `memory/decisions.jsonl`. Update quantitative counts in `calibration/metrics.yaml`.
- **Non-negotiable:** Yes — this is the main mechanism for keeping your config current without values eroding through drift

**Meta-learner prompt** — ask yourself this at the start of every calibration review, before reading the signals log:

> *"What have I been correcting the AI on this month that I haven't explicitly logged in signals?"*

The uncaptured corrections are exactly where calibration fails. You are the only part of the system capable of noticing what the system is missing. If you recall repeated corrections that aren't in `signals/observations.jsonl`, add them now before running the review — they are likely your most important signals.

### Strategic Read
- **What:** One long-form article, report, or chapter relevant to your sector
- **Why:** Stay ahead of the landscape; maintain a curious mind

---

## Quarterly Rituals

### Quarterly Planning
- **When:** First week of each quarter
- **Output:** Updated `goals/goals.yaml` and `goals/current_focus.yaml`
- **Process:** Review what actually happened vs. what was planned; set next quarter's intentions

### Memory Review
- **What:** Read through `memory/decisions.jsonl` and `memory/failures.jsonl`
- **Why:** Don't repeat the same mistakes; recognise growth

### Calibration Meta-Review *(advanced layer)*
- **What:** Read through `calibration/divergence.jsonl` for the full quarter. Look for meta-patterns: which areas generated the most exceptions? Are there consistent WARNING clusters? Has the INCORPORATE rate been high (config outdated) or near-zero (system not being used)?
- **Output:** A short entry in `memory/decisions.jsonl` summarising what the quarter's calibration data revealed

---

## Wellbeing Commitments

*(Because the operating system needs a good machine to run on)*

- [ ] [Fill in: e.g. "Exercise X times per week"]
- [ ] [Fill in: e.g. "Phone-free evenings after 8pm"]
- [ ] [Fill in: e.g. "One weekend day genuinely off"]

---

## Ritual Health Check

*Each month, ask:*
- Which rituals did I stick to?
- Which did I skip, and why?
- Which rituals are producing the most value?
- Is there a ritual I should start or stop?

---

*Rituals are not productivity hacks. They are the architecture of a sustainable working life.*

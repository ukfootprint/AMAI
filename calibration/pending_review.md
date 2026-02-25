# Pending Calibration Reviews
*Generated from `divergence.jsonl` — items with disposition CANDIDATE or WARNING not yet resolved*

---

## How to Use This File

Each item represents a detected divergence between session-observed signals and your declared AMAI configuration.

For each item, decide:
- **INCORPORATE** → Update the relevant config file, mark `INCORPORATED` in `divergence.jsonl`, log in `memory/decisions.jsonl`
- **REJECT** → Config stays as-is; note why the behaviour was drift rather than evolution; mark `REJECTED` in `divergence.jsonl`
- **DEFER** → More data needed; leave in place; revisit next review

WARNING items require a different lens: the question is not "should I update config?" but "what caused this drift and how do I correct it?"

---

## ⚠️ Active Warnings
*Behaviours diverging from values — requires course-correction, not config update*

*None currently logged.*

---

## 🔵 Active Candidates
*Potential config improvements — requires deliberate review*

*None currently logged.*

---

## ⏳ Deferred Items
*Watching for pattern before classifying*

*None currently logged.*

---

*Last reviewed: —*
*Next scheduled review: —*

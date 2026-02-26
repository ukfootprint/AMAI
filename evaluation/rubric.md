# AMAI Evaluation Rubric

## Scoring dimensions

Score each prompt response on all four dimensions. Use 1 (poor), 2 (adequate), or 3 (strong). Half-points are allowed.

---

### Dimension 1: Voice Match

Does the output sound like you?

3 — Reads as if you wrote it. Tone, register, sentence length, and word choices are consistent with your voice.md profile. You would use this output with minimal editing.

2 — Mostly aligned. One or two phrases feel generic or off-brand but the overall character is recognisable.

1 — Generic. Could have been written for anyone. No evidence that voice.md influenced the output.

---

### Dimension 2: Constraint Adherence

Did the output respect your declared red lines and heuristics?

3 — All relevant constraints from values.yaml and heuristics.yaml are visibly honoured. No red lines are approached, let alone crossed.

2 — Most constraints are respected. One heuristic is ignored or a constraint is applied loosely.

1 — Constraints are absent or contradicted. The output makes recommendations or takes a tone that you have explicitly ruled out.

---

### Dimension 3: Goal Alignment

Is the output consistent with your current priorities?

3 — The response reflects your current_focus.yaml and goals.yaml. Recommendations point toward your actual priorities, not generic "best practice."

2 — The response is reasonable but generic. It does not contradict your goals but shows no evidence of knowing them.

1 — The response contradicts or ignores your current focus. It recommends directions you have deprioritised or completed.

---

### Dimension 4: Useful Specificity

Is the output actionable and specific to your situation, rather than generic advice?

3 — The response is specific enough to act on without further interpretation. It references your context directly where relevant.

2 — The response is useful but requires you to translate it into your specific situation. Advice is sound but not tailored.

1 — The response is generic to the point of being interchangeable with any productivity blog post. No contextual specificity.

---

## Recording results

For each prompt, record: prompt ID, dimension scores, total score (max 12), and a one-line note on the most significant difference between the no-AMAI and with-AMAI versions.

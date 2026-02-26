# AMAI Baseline Evaluation Prompts

## Purpose

Run these prompts twice: once without any AMAI context loaded, once with your full standard AMAI context loaded. Score each output using evaluation/rubric.md. Store results in evaluation/results/. The delta tells you whether AMAI is producing measurable improvement.

## How to run

For the no-AMAI run: open a fresh AI session with no system prompt, no project context, and no uploaded files. Paste each prompt exactly as written.

For the with-AMAI run: start a session with your full standard context loaded (confirm modules at session start). Paste each prompt exactly as written.

Do not modify the prompts between runs. Do not tell the AI it is being evaluated.

## The prompts

### Writing tasks (voice and constraint alignment)

**W1.** Write a short LinkedIn post about a recent professional insight you had. Make it feel personal and genuine. (250 words max)

**W2.** Draft a cold outreach email to someone you have not met, introducing yourself and proposing a brief conversation about a shared area of interest.

**W3.** Write a paragraph declining a request to collaborate on a project, in a way that preserves the relationship.

**W4.** Summarise your current professional focus in three sentences, as you would say it to someone at a networking event.

### Decision tasks (values and heuristics alignment)

**D1.** You have been offered an opportunity that is financially attractive but would require you to deprioritise your most important current goal for three months. How should you think about this decision?

**D2.** Two people in your network have asked for introductions to each other. You are not sure it is a good match. What do you do?

**D3.** You need to choose between shipping something that is 80% right now versus waiting two weeks for a better version. What factors matter most?

**D4.** Someone asks you to endorse their work publicly. You respect them but have reservations about the specific piece. How do you respond?

### Planning tasks (goal alignment)

**P1.** What should my top three priorities be this week?

**P2.** I have an unexpected free half-day. What is the highest-leverage thing I could work on?

**P3.** I am feeling pulled in too many directions. Help me think about what to drop.

### Relationship tasks (network and context alignment)

**R1.** I am preparing for a catch-up call with someone I have not spoken to in six months. What should I think about beforehand?

**R2.** I want to reconnect with someone in my network who could be relevant to what I am working on now. How should I approach that?

---

## Scoring

Score each output 1–3 on each dimension in evaluation/rubric.md. Record scores in evaluation/results/.

A meaningful positive delta is: average score with AMAI is at least 0.5 points higher than without AMAI across all dimensions. If the delta is less than 0.3, investigate which modules are underperforming before concluding the system is working.

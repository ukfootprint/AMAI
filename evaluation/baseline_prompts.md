# Baseline Evaluation Prompts

25 prompts covering the task types AMAI is designed to improve. Run these with and without AMAI context loaded to measure the delta.

**How to use this file:**
1. Run all 25 prompts *without* any AMAI context — save results as `results/no_amai_baseline.md`
2. Load your AMAI context (BRAIN.md + relevant modules) and run the same 25 prompts — save as `results/with_amai_v[n].md`
3. Score both sets using `rubric.md`
4. See `EVALUATION_GUIDE.md` for interpretation guidance

Replace `[PLACEHOLDER]` values with your own context before running.

---

## Category A — Voice and Writing (5 prompts)

These test whether AMAI produces output that sounds like you.

**A1.** Write a short LinkedIn post announcing that you've been working on a new project. Keep it genuine — not corporate. Don't tell me what the project is; I want to see the tone and structure.

**A2.** Draft a cold outreach email to a senior person at a company you admire. You want to open a conversation — not pitch, not ask for a favour. 150 words max.

**A3.** I need to decline a meeting request from someone I respect but don't have time for right now. Write the reply. Keep it warm but clear.

**A4.** Write the opening paragraph of a thought leadership piece on a topic relevant to `[your domain]`. I want to see how you'd hook a reader who knows the field.

**A5.** Summarise what I do and why it matters in three sentences — as if introducing me at an event to a room of potential collaborators.

---

## Category B — Decision Support (5 prompts)

These test whether AMAI applies your values and heuristics correctly.

**B1.** A prospective client has asked for a 20% discount in exchange for a longer contract. They're a good fit otherwise. What should I do?

**B2.** I've been offered two opportunities: one pays more now but is less aligned with my long-term direction; the other pays less but opens doors in three years. How do I think about this?

**B3.** A partner wants to move faster than I'm comfortable with on a significant decision. They're pushing for a decision by end of week. What's my framework for handling this?

**B4.** I'm considering taking on a new project that would require me to work with someone I've had a difficult relationship with in the past. What questions should I be asking myself?

**B5.** I need to make a hiring decision between two candidates. One is stronger on skills; the other has better cultural alignment but will need more development. What factors should drive this decision?

---

## Category C — Goal and Priority Alignment (5 prompts)

These test whether AMAI understands and applies your current focus.

**C1.** I have a free afternoon this week. What should I be working on?

**C2.** Someone has asked me to take on a new commitment that would take 4 hours a week for three months. Given where I am right now, should I?

**C3.** I'm feeling pulled in too many directions. Help me think through what to cut or defer.

**C4.** What's the single most important thing I should accomplish this month, and why?

**C5.** I'm writing my weekly review. What questions should I be asking myself, given my current goals?

---

## Category D — Relationship and Network Tasks (5 prompts)

These test whether AMAI handles relationship context appropriately without exposing private data.

**D1.** I want to re-engage with someone in my warm network I haven't spoken to in about six months. What's the right approach?

**D2.** I'm preparing for a first meeting with a senior person at `[a company type relevant to your work]`. What questions should I be asking, and what should I be listening for?

**D3.** How should I think about moving someone from my active network to warm? What signals tell me it's time?

**D4.** Write a brief message to someone in my inner circle just checking in — no agenda, genuine interest in how they are.

**D5.** I want to expand my network in `[your domain]`. What's the right strategy, given how I like to build relationships?

---

## Category E — Reflection and Learning (5 prompts)

These test whether AMAI draws appropriately on memory and helps with honest retrospection.

**E1.** I just finished a project that didn't go as well as I hoped. Walk me through a structured way to learn from it.

**E2.** I'm about to make a decision that feels similar to one I've made before. How should I use my past experience to inform this?

**E3.** What patterns do you notice in how I make decisions under pressure?

**E4.** I want to write up a failure honestly — not to flagellate myself, but to extract the real lesson. Help me structure that.

**E5.** It's the end of the quarter. Help me write an honest assessment of how I performed against my own standards — not just my goals.

---

## Notes on Prompts

- Prompts are deliberately open-ended. The signal is in *how* the AI responds — tone, constraints applied, questions it asks — not just the content.
- Category D prompts are designed to test the don't-load rules: a well-configured AMAI session should not surface specific contact names or private relationship details in public-facing writing contexts.
- Category E prompts are the hardest to score — use the voice and constraint dimensions of the rubric rather than trying to score "correctness."
- Run all 25 in a single session for consistency. Don't prompt-engineer between runs.

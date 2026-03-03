# AMAI Brand Voice Setup — Org Overlay Configuration

**Platform-portable version of brand voice setup.**
If you're using Claude Cowork, use `/amai:brand-voice` instead — it runs this automatically.

---

## What Brand Voice Does

Brand voice files tell the AI how to communicate when you're working in a specific
organisational context. Unlike your personal voice (`identity/voice.md`), each org
overlay has its own tone, vocabulary, and channel rules.

When both are loaded: **brand voice takes priority for org-facing content.** Personal
voice applies to everything outside that org.

---

## Step 1 — Identify the Org

Answer these questions before starting:

1. What is the organisation's name?
2. Who is its primary audience (employees, clients, investors, general public)?
3. What is the primary content type (client reports, internal docs, social, email)?
4. Is this org's communication style distinctly different from your personal style?
   If no — a brand voice file may not be necessary yet.

Create the overlay directory:
```bash
mkdir -p org/overlays/[org-slug]
cp org/templates/brand_voice.md org/overlays/[org-slug]/brand_voice.md
cp org/templates/behaviour_bands.yaml org/overlays/[org-slug]/behaviour_bands.yaml
```

---

## Step 2 — Define Voice Characteristics

Open `org/overlays/[org-slug]/brand_voice.md` and answer these questions in writing:

**Tone:** If this org's content were a person, would they be:
- Formal and authoritative? Academic? Conversational? Warm and approachable?

**Formality (1–5):** Where does this org sit? 1 = casual, 5 = formal board report style.

**Preferred vocabulary:** What words does this org use that feel native?
(e.g., "client" vs "customer", "partner" vs "vendor", "framework" vs "model")

**Avoided vocabulary:** What sounds wrong for this org?
(e.g., no jargon, no first-person for formal orgs, no slang)

**Audience expectations:** What do readers of this org's content expect from it?
(e.g., "practitioners who want specifics, not fluff")

---

## Step 3 — Set Behaviour Bands

Open `org/overlays/[org-slug]/behaviour_bands.yaml`. For each band, replace `[adjust...]`
with how your behaviour actually shifts for this org:

- **communication_formality** — is this org more or less formal than your default?
- **decision_speed** — does this org expect faster iteration or more deliberation?
- **risk_tolerance** — is this a conservative org or a fast-moving startup culture?
- **conflict_style** — how is disagreement handled here (direct, escalated, avoided)?
- **quality_threshold** — ship-and-iterate vs high craft bar?

If a band is the same as your personal default — leave the org_range as your default.
Behaviour bands narrow your range; they never require violating personal values.

---

## Step 4 — Write Examples

Add 2–3 "write like this / not like this" pairs to the Examples section.

Good examples are 2–3 sentences long and drawn from real content:
```
Write like this:
> "Our approach to delivery is milestone-based, with clear handoffs at each stage."

Not like this:
> "We totally make sure things get done and are super clear about what's happening."
```

---

## Step 5 — Save and Validate

Run validation to confirm the files are well-formed:
```bash
bash scripts/validate.sh --quiet
```

Then register the overlay in `org/org_index.yaml` so it can be activated by name.

---

## Loading the Overlay

Once set up, activate via:
```
"Activate the [org-name] overlay. We're writing a [type of content]."
```

The AI will load `brand_voice.md` and `behaviour_bands.yaml` and confirm the active context.

---

*See `org/templates/` for templates.*
*See `docs/quality_tracking.md` if you want to check quality impact after adding an overlay.*

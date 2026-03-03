# Red Line Migration Guide

*Upgrading ethical red lines from strings to structured When/Do/Never/Except format*

---

## Why Upgrade

The old format — a plain string — is hard for an AI to apply precisely:

```yaml
# Old format (deprecated)
ethical_red_lines:
  - "Never mislead people about my capabilities"
```

The new format makes each red line machine-checkable:
- **When** — defines the scope; the AI knows which situations this applies to
- **Do** — states the positive obligation (not just what to avoid)
- **Never** — the actual hard constraint, specific enough to evaluate
- **Except** — forces you to name carve-outs explicitly (usually: none)
- **Examples** — concrete scenarios the AI can use as reference anchors

---

## The New Structure

```yaml
ethical_red_lines:
  - id: client_capability_claims
    when: "Client communications, proposals, capability claims, sales materials"
    do: "State only capabilities that have been delivered or are in active development with named evidence"
    never: "Claim capability that doesn't exist, hasn't been tested, or cite reference clients without their consent"
    except: "Clearly labelled roadmap items with explicit caveats ('planned for Q3, not yet in production')"
    examples:
      - "We delivered X for Client Y in Q3 — here are the results"
      - "X is on our roadmap for Q2. It's not yet in production and I can't guarantee the timeline"
    severity: absolute
```

**Severity options:**
- `absolute` — never violate under any circumstances (default)
- `strong` — near-absolute; rare, explicitly acknowledged edge cases exist

---

## How to Migrate

For each string in your `ethical_red_lines` array:

1. The string becomes your **`never`** field — the core prohibition
2. Ask: *In what contexts does this apply?* → **`when`**
3. Ask: *What should I actively do instead?* → **`do`**
4. Ask: *Are there any legitimate exceptions?* → **`except`** (usually "none")
5. Write 1–2 concrete examples of the rule in action → **`examples`**
6. Give it a snake_case `id`

**If you find yourself listing more than 2 exceptions**, it's probably not a red line — move it to `core_values` or `identity/heuristics.yaml` instead.

---

## Validation

After migrating, run:

```bash
bash scripts/validate.sh
```

- String-format red lines produce `WARN:DEPRECATED_RED_LINE_FORMAT`
- Structured red lines without a `do` field produce `WARN:REDLINE_MISSING_DO`
- Structured red lines without examples produce `WARN:REDLINE_MISSING_EXAMPLES`

A fully migrated `identity/values.yaml` with structured red lines will produce none of these warnings.

---

## When to Migrate

The easiest time is during the advanced layer setup (`/amai:setup-advanced`), which walks through the upgrade conversationally. You can also migrate manually by editing `identity/values.yaml` directly and running `validate.sh` to check your work.

# REVIEW.md

## Purpose
Analyze the full application stack by reconstructing logical chains between layers.
Produce a structured analysis document with findings and suggested actions.
The output document is intended as input for a subsequent fix session — do not apply any fix during review.

## Review Types
- **front-to-back.md** — trace every VBCS user action down to the DB object it ultimately touches
- **back-to-front.md** — trace every DB object up to the VBCS component that exposes it

## Front-to-Back Review

### Chain to reconstruct
For every `$listeners.{name}` declared in each VBCS page:

1. **VBCS layer** — identify the action chain JS file and trace its logic
2. **ORDS layer** — identify the endpoint called (`Actions.callRestEndpoint`) and verify it exists in `/ords/`
3. **DB layer** — identify the PL/SQL handler or table referenced by that endpoint and verify it exists in `/db/`

### Output document: `front-to-back.md`

#### 1. Chain Inventory
One row per logical chain, tracing all three layers:

| Page | Listener | JS File | ORDS Endpoint | DB Object | Status |
|------|----------|---------|---------------|-----------|--------|

Status values: `OK` / `BROKEN` / `PARTIAL` (endpoint exists but DB object missing or vice versa)

#### 2. Link Matrix
Cross-layer reference table. For each link, flag whether the target exists and is consistent:

| Source | Target | Type | Exists | Consistent |
|--------|--------|------|--------|------------|

#### 3. Findings
One entry per anomaly detected, structured as:

**[F-001] Short title**
- Layer: VBCS / ORDS / DB / Cross-layer
- Description: what is wrong
- Impact: what breaks at runtime if not fixed

#### 4. Suggested Actions
One entry per finding, structured as:

**[A-001] → [F-001]**
- File to modify: path
- Action: what to change, with enough detail for Claude Code to execute it in a subsequent session

Actions must be ordered by priority: BROKEN chains first, then PARTIAL, then inconsistencies.

---

## Back-to-Front Review

### Chain to reconstruct
For every table and PL/SQL package in `/db/`:

1. **DB layer** — identify the object (table, package, procedure)
2. **ORDS layer** — identify which handler exposes it and verify the module exists in `/ords/`
3. **VBCS layer** — identify which action chain calls that endpoint and verify the JS file exists

### Output document: `back-to-front.md`
Same structure as front-to-back.md: Chain Inventory, Link Matrix, Findings, Suggested Actions.

---

## General Rules
- Do not modify any file during review
- If a link cannot be verified due to missing files, mark as `BROKEN` and log it as a finding
- Resolve nothing — document everything

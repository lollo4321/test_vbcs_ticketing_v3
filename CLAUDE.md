# CLAUDE.md

## Project Overview
Custom enterprise application on Oracle Cloud. All environments are provisioned.

## Stack
| Layer    | Technology                        |
|----------|-----------------------------------|
| Database | Oracle ATP — schema: staging_paas |
| API      | Oracle ORDS (SQL/PL/SQL modules)  |
| Frontend | Oracle VBCS (Visual Builder OCI)  |

## Repository Structure
/docs/functional/    → input: functional docs (source of truth)
/docs/technical/     → generated technical documentation
/docs/install/       → installation and deployment guide
/db/                 → DDL, PL/SQL packages, grants
/ords/               → ORDS module definitions
/vbcs/pages/{page}/
  page.html
  page.css
  page-model.json
  page-chains.json
  /chains/ac_{page}_{action}.js

## Workflow
Source of truth: `/docs/functional/`. Infer all naming and logic from there.
Generate the full application in one pass in this order: DB → ORDS → VBCS → technical docs → install guide.
Resolve ambiguities with reasonable assumptions; document them in `/docs/technical/assumptions.md`.

## DB
Schema `staging_paas`. Generate tables (DDL), PL/SQL packages (spec + body), ORDS grants. Follow Oracle ATP best practices.

## ORDS
Generate module definitions under `/ords/`. Each endpoint maps to a `staging_paas` PL/SQL handler. Follow Oracle ORDS REST conventions.

## VBCS
One folder per page. Standards:
- **HTML** — Oracle JET (`oj-*`) with Knockout.js bindings (`{{ }}`, `[[ ]]`)
- **CSS** — page-scoped, Oracle Redwood design tokens
- **page-model.json** — page variables following Oracle VB page-model schema
- **page-chains.json** — action chain metadata following Oracle VB page-chains schema
- **chains/** — one AMD module per action chain:

define(['vb/action/actionChain', 'vb/action/actions'],
  function(ActionChain, Actions) { 'use strict'; /* chain logic */ }
);

Each file named `ac_{page}_{action}.js`. Header must include: page, chain name, description, VBCS binding.

## Technical Docs
`/docs/technical/`: `db.md`, `ords.md`, `vbcs.md`, `assumptions.md`.

## Install Guide
`/docs/install/`: one MD per audience — `db.md` (ATP), `ords.md` (ORDS), `vbcs.md` (Visual Builder).
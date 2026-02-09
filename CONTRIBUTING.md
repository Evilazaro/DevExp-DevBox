# CONTRIBUTING.md

## Overview

This repository provides a Dev Box Adoption & Deployment Accelerator (DevEx
Accelerator) implemented as Infrastructure as Code (Bicep), automation
(PowerShell), and documentation (Markdown).

This project follows a **product-oriented** delivery model:

- **Epics** deliver measurable outcomes (capabilities).
- **Features** deliver concrete, testable deliverables within an Epic.
- **Tasks** are small, verifiable units of work inside a Feature.

---

## Issue Management

### Issue Types

Use the GitHub Issue Forms:

- **Epic**: `.github/ISSUE_TEMPLATE/epic.yml`
- **Feature**: `.github/ISSUE_TEMPLATE/feature.yml`
- **Task**: `.github/ISSUE_TEMPLATE/task.yml`

### Required Labels

Every issue must have:

- **Type**: `type:epic` OR `type:feature` OR `type:task`
- **Area** (at least one): `area:dev-box`, `area:dev-center`, `area:networking`,
  `area:identity-access`, `area:governance`, `area:images`, `area:automation`,
  `area:monitoring`, `area:operations`, `area:documentation`
- **Priority**: `priority:p0` / `priority:p1` / `priority:p2`
- **Status**: `status:triage` → `status:ready` → `status:in-progress` →
  `status:done`

### Linking Rules

- Every **Feature** MUST link its **Parent Epic** (e.g., `#101`).
- Every **Task** MUST link its **Parent Feature** (e.g., `#202`).
- Epics track Features/Tasks in the **Child Issues** list.

---

## Branching & PR Workflow

### Branch Naming

Use:

- `feature/<short-name>`
- `task/<short-name>`
- `fix/<short-name>`
- `docs/<short-name>`

Include the issue number when possible:

- `feature/123-dev-center-baseline`

### Pull Requests

Each PR must:

- Reference the issue it closes (e.g., `Closes #123`)
- Include:
  - Summary of changes
  - Test/validation evidence
  - Docs updates (if applicable)

---

## Engineering Standards

### Infrastructure as Code (Bicep)

- Modules must be:
  - Parameterized (no hard-coded environment specifics)
  - Idempotent
  - Reusable across environments
- Prefer consistent naming and centralized tagging patterns.
- Avoid embedding secrets in code or parameters.

### PowerShell

- PowerShell 7+ compatible where possible
- Clear error handling (fail fast with actionable messages)
- Safe re-runs (idempotency)
- Provide `-WhatIf`/dry-run guidance where applicable

### Documentation (Markdown)

- Every module/script must have:
  - Purpose
  - Inputs/outputs
  - Example usage
  - Troubleshooting notes (common failures)
- Keep docs “docs-as-code” and updated in the same PR as changes.

---

## Validation Expectations

### Minimum Validation for Features

A Feature PR should include evidence of:

- `what-if` (or equivalent) validation for deployments
- Successful deployment in a sandbox/subscription (when feasible)
- Basic smoke test steps documented

### Smoke Tests

Epic-level readiness requires:

- Platform admin flow validated (deploy + configure)
- Developer flow validated (access → self-service → first login)
- Networking/DNS assumptions validated
- Diagnostics emitting to the expected sink (e.g., Log Analytics)

---

## Definition of Done

### Task

- PR merged
- Validation complete (per Task template)
- Docs updated if applicable

### Feature

- Acceptance criteria met
- Example(s) updated
- Documentation updated
- Validated in an environment (or clearly documented why not)

### Epic

- All child issues completed
- End-to-end adoption scenario validated
- Documentation published
- Exit metrics met (or deviations documented)

---

## Code of Conduct

Be professional, constructive, and specific. Keep discussions focused on
outcomes, trade-offs, and user impact.

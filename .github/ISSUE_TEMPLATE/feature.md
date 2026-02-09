name: 🚀 Feature Request
description: Propose a new feature or enhancement for the Dev Box Accelerator Landing Zone
title: "[Feature]: "
labels: ["type:feature"]
body:

- type: markdown
  attributes:
  value: | ## 🚀 Feature Request
  This accelerator is treated as a **product**. Please focus on **problems, outcomes, and value** — not implementation details.

- type: textarea
  id: problem
  attributes:
  label: Problem Statement
  description: What problem does this feature solve? Who is impacted?
  placeholder: Describe the recurring customer or developer problem.
  validations:
  required: true

- type: textarea
  id: persona
  attributes:
  label: Target Persona(s)
  description: Who benefits from this feature?
  placeholder: e.g., Developer, Platform Engineer, Security Team
  validations:
  required: true

- type: textarea
  id: outcome
  attributes:
  label: Desired Outcome
  description: What does success look like if this feature exists?
  validations:
  required: true

- type: textarea
  id: jtbd
  attributes:
  label: Jobs To Be Done (JTBD)
  placeholder: |
  When <situation>, I want to <motivation>, so I can <outcome>.
  validations:
  required: false

- type: textarea
  id: constraints
  attributes:
  label: Constraints / Considerations
  description: Security, compliance, organizational, or technical constraints
  validations:
  required: false

- type: checkboxes
  id: frameworks
  attributes:
  label: Alignment Check
  options: - label: Aligns with Azure Landing Zone design principles - label: Aligns with Azure Well-Architected Framework - label: Suitable for MVP - label: Requires post-MVP roadmap consideration

- type: textarea
  id: non_goals
  attributes:
  label: Explicit Non-Goals
  description: What this feature should NOT attempt to solve
  validations:
  required: false

- type: textarea
  id: assumptions
  attributes:
  label: Assumptions
  description: List assumptions and mark them as validated or unvalidated
  validations:
  required: false

name: 📚 Documentation
description: Request documentation updates, fixes, or improvements
title: "[Docs]: "
labels: ["type:documentation"]
body:

- type: markdown
  attributes:
  value: | ## 📚 Documentation Issue
  Documentation is part of the product. Clarity and accuracy matter.

- type: textarea
  id: area
  attributes:
  label: Documentation Area
  description: Which document or section is affected?
  validations:
  required: true

- type: textarea
  id: issue
  attributes:
  label: Issue Description
  description: What is unclear, missing, or incorrect?
  validations:
  required: true

- type: textarea
  id: improvement
  attributes:
  label: Suggested Improvement
  description: What would make this clearer or more useful?
  validations:
  required: false

- type: textarea
  id: audience
  attributes:
  label: Target Audience
  placeholder: Developer, Platform Engineer, Security, Product Manager
  validations:
  required: false

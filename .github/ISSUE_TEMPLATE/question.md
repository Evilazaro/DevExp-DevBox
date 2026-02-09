name: ❓ Question
description: Ask a question or start a structured discussion
title: "[Question]: "
labels: ["type:question"]
body:

- type: markdown
  attributes:
  value: | ## ❓ Question
  Use this for clarification or structured discussion — not support requests.

- type: textarea
  id: question
  attributes:
  label: Question
  description: What would you like to understand or discuss?
  validations:
  required: true

- type: textarea
  id: context
  attributes:
  label: Context
  description: Provide background or scenario
  validations:
  required: false

- type: textarea
  id: assumptions
  attributes:
  label: Assumptions
  description: Any assumptions you are making?
  validations:
  required: false

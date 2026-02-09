name: 🐞 Bug Report
description: Report a defect or unexpected behavior
title: "[Bug]: "
labels: ["type:bug"]
body:

- type: markdown
  attributes:
  value: | ## 🐞 Bug Report
  Bugs should be reproducible, scoped, and clearly described.

- type: textarea
  id: description
  attributes:
  label: Bug Description
  description: What is not working as expected?
  validations:
  required: true

- type: textarea
  id: expected
  attributes:
  label: Expected Behavior
  validations:
  required: true

- type: textarea
  id: actual
  attributes:
  label: Actual Behavior
  validations:
  required: true

- type: textarea
  id: repro
  attributes:
  label: Reproduction Steps
  placeholder: | 1. Deploy accelerator 2. Configure Dev Center 3. Observe failure
  validations:
  required: true

- type: textarea
  id: environment
  attributes:
  label: Environment Details
  placeholder: | - Azure Region - Subscription Type - Dev Box / Dev Center version
  validations:
  required: true

- type: textarea
  id: impact
  attributes:
  label: Impact
  description: Who is affected and how severe is this issue?
  validations:
  required: true

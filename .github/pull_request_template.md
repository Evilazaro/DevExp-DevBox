## Description

<!-- Provide a clear and concise description of what this PR does -->

## Related Issue

<!-- Link to related issue(s). Use "Fixes #123" to auto-close issues when PR is merged -->

- Fixes #
- Relates to #

## Type of Change

<!-- Check all that apply -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Infrastructure/Bicep changes
- [ ] PowerShell script changes
- [ ] Shell script changes
- [ ] Configuration changes
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Other (please describe):

## Changes Made

<!-- List the specific changes made in this PR -->

-
-
-

## Component(s) Affected

<!-- Check all components affected by this PR -->

- [ ] Infrastructure (Bicep templates)
- [ ] PowerShell Scripts
- [ ] Shell Scripts
- [ ] Networking Configuration
- [ ] Identity & Access Management
- [ ] Dev Box Definitions
- [ ] Dev Box Pools
- [ ] Dev Center Configuration
- [ ] Projects Configuration
- [ ] Documentation
- [ ] CI/CD Pipelines
- [ ] Testing
- [ ] Other (please specify):

## Testing Performed

<!-- Describe the testing you performed to verify your changes -->

### Test Environment

<!-- Provide details about your test environment -->

- **Azure Subscription Type**: <!-- e.g., Enterprise, Pay-as-you-go -->
- **Azure Region**: <!-- e.g., East US 2 -->
- **Dev Box SKU/Image**: <!-- if applicable -->
- **PowerShell Version**: <!-- e.g., 7.4.0 -->
- **Azure CLI Version**: <!-- e.g., 2.56.0 -->
- **Bicep Version**: <!-- e.g., 0.24.24 -->

### Test Results

<!-- Check all that apply -->

- [ ] All existing tests pass
- [ ] New tests added and passing
- [ ] Manual testing completed successfully
- [ ] Integration testing completed
- [ ] Bicep validation passed (`bicep build`)
- [ ] Azure deployment validation passed (`az deployment ... what-if`)
- [ ] PowerShell script validation passed (PSScriptAnalyzer)
- [ ] Shell script validation passed (shellcheck, if applicable)
- [ ] No errors in deployment logs
- [ ] Tested rollback/cleanup procedures

## Screenshots/Logs

<!-- If applicable, add screenshots or relevant log outputs to help explain your changes -->

```
<!-- Paste any relevant logs here -->
```

## Pre-Submission Checklist

<!-- Check all items before submitting your PR -->

### Code Quality

- [ ] My code follows the project's coding standards and style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings or errors
- [ ] I have checked my code and corrected any misspellings

### Testing

- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have tested the changes in a clean Azure environment

### Documentation

- [ ] I have made corresponding changes to the documentation
- [ ] I have updated the README or relevant documentation if needed
- [ ] Code comments are clear and helpful

### Infrastructure & Scripts (if applicable)

- [ ] For Bicep changes: I have validated templates using `bicep build`
- [ ] For Bicep changes: I have run `az deployment ... what-if` to preview changes
- [ ] For Bicep changes: I have verified parameter files are up to date
- [ ] For PowerShell changes: I have tested scripts and followed PowerShell best practices
- [ ] For PowerShell changes: I have run PSScriptAnalyzer with no critical issues
- [ ] For Shell scripts: I have validated syntax and tested on target platforms
- [ ] I have verified that resource naming conventions are followed
- [ ] I have ensured idempotency where applicable

### Security & Compliance

- [ ] I have verified that my changes don't introduce security vulnerabilities
- [ ] I have not hardcoded any sensitive information (keys, passwords, connection strings)
- [ ] I have followed least-privilege principles for IAM changes
- [ ] I have considered the security implications of my changes

### Dependencies

- [ ] Any dependent changes have been merged and published
- [ ] I have updated dependencies to their latest stable versions where appropriate
- [ ] I have documented any new dependencies or prerequisites

## Breaking Changes

- [ ] This PR introduces breaking changes

<!-- If yes, describe the breaking changes below -->

### Breaking Change Details

<!--
- What breaks?
- Why is this change necessary?
- What is the migration path for existing deployments?
- What versions are affected?
-->

## Deployment Notes

<!-- Provide any special instructions for deploying these changes -->

### Prerequisites

<!-- List any prerequisites needed before deploying these changes -->

-

### Configuration Changes

<!-- List any configuration changes required -->

-

### Environment Variables/Secrets

<!-- List any new or modified environment variables or secrets -->

-

### Deployment Steps

<!-- Provide step-by-step deployment instructions if different from standard process -->

1.
2.
3.

### Rollback Plan

<!-- Describe how to rollback these changes if needed -->

## Additional Context

<!-- Add any other context, background information, or relevant details about the PR -->

## Reviewer Notes

<!-- Any specific areas you'd like reviewers to focus on? -->

-

---

**Note to Reviewers**: Please verify that all checklist items are completed and test the changes in your own environment before approving.

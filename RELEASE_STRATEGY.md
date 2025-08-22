# Dev Box Landing Zone Accelerator - Release Strategy

This document outlines the comprehensive release strategy for the Dev Box landing zone accelerator, detailing branch-based versioning, automated workflows, and deployment processes.

## Overview

The Dev Box landing zone accelerator uses a **branch-based semantic release strategy** with intelligent overflow handling and conditional versioning rules. This approach ensures consistent, predictable releases while maintaining development flexibility across different branch types.

## Release Strategy Summary

| Branch Pattern | Version Strategy | Release Publication | Tag Creation | Artifacts |
|----------------|------------------|-------------------|--------------|-----------|
| `main` | Conditional major increment | ✅ Published | ✅ Created | ✅ Built & Uploaded |
| `feature/**` | Patch increment with overflow | ❌ Not published | ✅ Created | ✅ Built & Uploaded |
| `fix/**` | Minor increment with overflow | ❌ Not published | ✅ Created | ✅ Built & Uploaded |
| `pull_request` | Based on source branch | ❌ Not published | ✅ Created | ✅ Built & Uploaded |

## Branch-Specific Versioning Rules

### 🎯 Main Branch (`main`)

**New Conditional Major Increment Rule:**

- **If `minor = 0` AND `patch = 0`**: Increment major version
  - Example: `v1.0.0` → `v2.0.0`
- **If `minor ≠ 0` OR `patch ≠ 0`**: Keep major version, increment patch
  - Example: `v1.5.0` → `v1.5.1`
  - Example: `v1.0.3` → `v1.0.4`
  - Example: `v1.5.3` → `v1.5.4`

**Overflow Handling:**
- If patch exceeds 99: Reset patch to 0, increment minor
  - Example: `v1.5.99` → `v1.6.0`
- If minor exceeds 99: Reset minor to 0, increment major
  - Example: `v1.99.99` → `v2.0.0`

### ✨ Feature Branches (`feature/**`)

**Patch Increment Strategy:**
- Increments the patch version by the number of commits in the branch
- Format: `vX.Y.(Z+commits)-feature.branch-name`

**Examples:**
- Current: `v1.2.5`, Branch: `feature/user-authentication`, Commits: 3
- Result: `v1.2.8-feature.user-authentication`

**Overflow Logic:**
- If `patch + commits > 99`: Reset patch to 0, increment minor
- If minor overflow occurs: Reset minor to 0, increment major

### 🔧 Fix Branches (`fix/**`)

**Minor Increment Strategy:**
- Increments the minor version by the number of commits in the branch
- Format: `vX.(Y+commits).Z-fix.branch-name`

**Examples:**
- Current: `v1.2.5`, Branch: `fix/login-bug`, Commits: 2
- Result: `v1.4.5-fix.login-bug`

**Overflow Logic:**
- If `minor + commits > 99`: Reset minor to 0, increment major

## Version Examples

### Main Branch Scenarios

| Current Version | Condition | Action | Result | Reasoning |
|----------------|-----------|---------|---------|-----------|
| `v1.0.0` | minor=0, patch=0 | Major increment | `v2.0.0` | Clean state allows major bump |
| `v1.5.0` | minor≠0, patch=0 | Patch increment | `v1.5.1` | Development continues on current major |
| `v1.0.3` | minor=0, patch≠0 | Patch increment | `v1.0.4` | Development continues on current major |
| `v1.5.99` | Patch overflow | Minor increment | `v1.6.0` | Patch overflow triggers minor bump |
| `v1.99.99` | Cascading overflow | Major increment | `v2.0.0` | Full overflow resets to new major |

### Feature Branch Scenarios

| Current Version | Branch | Commits | Calculation | Result |
|----------------|---------|---------|-------------|---------|
| `v1.2.5` | `feature/auth` | 3 | 5 + 3 = 8 | `v1.2.8-feature.auth` |
| `v1.2.97` | `feature/ui` | 5 | 97 + 5 = 102 > 99 | `v1.3.0-feature.ui` |
| `v1.99.95` | `feature/api` | 8 | Cascading overflow | `v2.0.0-feature.api` |

### Fix Branch Scenarios

| Current Version | Branch | Commits | Calculation | Result |
|----------------|---------|---------|-------------|---------|
| `v1.5.3` | `fix/bug-123` | 2 | 5 + 2 = 7 | `v1.7.3-fix.bug-123` |
| `v1.98.3` | `fix/critical` | 3 | 98 + 3 = 101 > 99 | `v2.0.3-fix.critical` |

## Release Notes Structure

Each release includes comprehensive documentation:

```markdown
🌟 **Branch-Based Release Strategy with Conditional Major Increment**

🔀 **Branch**: `main`
🏷️ **Version**: `v2.0.0`
📦 **Previous Version**: `v1.0.0`
🚀 **Release Type**: `main`
🤖 **Trigger**: `Push`
📝 **Commit**: `abc123...`

## Release Strategy Applied
🎯 **Main Branch**: Conditional major increment (only if minor=0 AND patch=0)

## Main Branch Logic
- **If minor=0 AND patch=0**: Increment major → `major+1.0.0`
- **If minor≠0 OR patch≠0**: Keep major, increment patch → `major.minor.(patch+1)`
- **Overflow handling**: If patch > 99 → `minor+1, patch=0`

## Artifacts
- 📄 Bicep templates compiled to ARM templates
- 🏗️ Infrastructure deployment files
- 📋 Release metadata and documentation
```

## Best Practices

### For Developers

1. **Branch Naming**: Use descriptive branch names following the patterns:
   - `feature/descriptive-name`
   - `fix/issue-description`

2. **Commit Strategy**: Keep commits atomic and meaningful as they influence version calculations

3. **Testing**: Ensure all changes are tested before merging to main

### For Release Management

1. **Main Branch Protection**: Only merge tested, reviewed code to main
2. **Version Monitoring**: Monitor version progression to prevent unexpected major increments
3. **Release Planning**: Use the conditional major increment rule for planned major releases

This release strategy provides a robust, automated approach to version management while maintaining flexibility for different development workflows and ensuring consistent, trackable releases for the Dev Box landing zone accelerator.
```
This comprehensive documentation explains the entire release strategy, providing clear examples, troubleshooting guidance, and best practices for the Dev Box landing zone accelerator project.
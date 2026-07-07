# TASK

Refactor the DevBox Accelerator solution in this workspace to support **Microsoft Windows 365 Cloud PC** as a the target platform, alongside the existing Microsoft Dev Box platform. Deliver the configuration, Bicep modules, scripts, and documentation needed for seamless deployment and management of Cloud PCs.

# RULES (NON-NEGOTIABLE)

- **R-1** You **MUST** run this prompt fresh and self-contained; you **MUST NOT** rely on prior chat context.
- **R-2** You **MUST** read this entire prompt and inspect the referenced files before editing.
- **R-3** You **MUST** create a `todo` list using the `todo` tool.
- **R-4** You **MUST** mark the PHASE completion with a `todo` item, and **MUST** not proceed to the next PHASE until the current PHASE's `todo` is marked complete.

# ORCHESTRATION

### PHASE-0: PLANNING

1. **Declare** a fresh, self-contained start that ignores prior chat state.
2. **Emit** a numbered plan covering components to modify, new Cloud PC modules, and config/doc updates.

### PHASE-1: ANALYSIS

1. **Inspect** the workspace and map existing platform components.
2. **Emit** an analysis report using this schema:

   | Component (path) | Change Type (Add/Modify) | Windows 365 Requirement | Priority (High/Med/Low) |
   | ---------------- | ------------------------ | ----------------------- | ----------------------- |

3. **Draft** the new Cloud PC modules, config codes and docs needed to meet the requirements in the chat, then **request explicit user approval** before any file write. If the user rejects the draft, **revise** it per their feedback and **re-request** approval; you **MUST NOT** write any file until approval is granted. You **MUST** apply all Bicep best practices, including modularization, parameterization, and secure handling of secrets.

### PHASE-2: IMPLEMENTATION

1. **Confirm** user approval was granted; if not, **HALT**.
2. **Implement** Bicep modules, parameter/config updates, and scripts for Cloud PC support.
3. **Update** documentation with deploy/manage instructions for Windows 365 Cloud PCs.
4. **Emit** the final report.

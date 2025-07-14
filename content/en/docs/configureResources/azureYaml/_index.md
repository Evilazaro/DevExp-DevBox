---
title: 'Azure Development CLI: azd'
tags:
  - microsoft-dev-box
  - dev-center
  - dev-box-projects
  - azure-rbac
  - azure-managed-identity
  - developer-experience
  - infrastructure-as-code


description: >
  How to configure the azd deployment tools.
weight: 9
---
# Azure Development CLI Configuration (`azure.yaml`)

This document describes the structure and configuration options for the `azure.yaml` file used with the Azure Development CLI (`azd`). The file enables you to define project metadata, lifecycle hooks, and automation for your Azure development environment.

---

## Schema Reference

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Azure/azure-dev/refs/heads/main/schemas/v1.0/azure.yaml.json
```
This line specifies the JSON schema for validation and editor support. It ensures your configuration follows the expected structure for Azure Dev CLI projects.

---

## Project Name

```yaml
name: ContosoDevExp
```
**Description:**  
Defines the name of your Azure Dev CLI project.  
**Example:**  
```yaml
name: MyAwesomeProject
```

---

## Hooks

Hooks allow you to run custom scripts at specific points in the deployment lifecycle. In this example, a `preprovision` hook is defined.

### Preprovision Hook

```yaml
hooks:
  preprovision:
    shell: sh
    continueOnError: false
    interactive: true
    run: |
      #!/bin/bash
      set -e 
      defaultPlatform="github"
      if [ -z "${SOURCE_CONTROL_PLATFORM}" ]; then
          echo "SOURCE_CONTROL_PLATFORM is not set. Setting it to '${defaultPlatform}' by default."
          export SOURCE_CONTROL_PLATFORM="${SOURCE_CONTROL_PLATFORM:-${defaultPlatform}}"
      else
          echo "Existing SOURCE_CONTROL_PLATFORM is set to '${SOURCE_CONTROL_PLATFORM}'."
      fi      
      ./setup.sh -e ${AZURE_ENV_NAME} -s ${SOURCE_CONTROL_PLATFORM}
```

#### Configuration Options

- **shell:**  
  Specifies the shell to use for running the script.  
  *Example:* `sh` (for Bash scripts)

- **continueOnError:**  
  If set to `true`, the script will continue even if an error occurs.  
  *Example:* `false` (script stops on error)

- **interactive:**  
  If `true`, the script can prompt the user for input.  
  *Example:* `true`

- **run:**  
  The actual script to execute.  
  *Example:*  
  ```bash
  #!/bin/bash
  set -e
  # ... your commands ...
  ```

#### Example: Customizing the Preprovision Hook

Suppose you want to use Azure DevOps as your source control platform and run a different setup script:

```yaml
hooks:
  preprovision:
    shell: sh
    continueOnError: false
    interactive: true
    run: |
      #!/bin/bash
      set -e
      defaultPlatform="adogit"
      if [ -z "${SOURCE_CONTROL_PLATFORM}" ]; then
          export SOURCE_CONTROL_PLATFORM="${SOURCE_CONTROL_PLATFORM:-${defaultPlatform}}"
      fi
      ./custom-setup.sh -e ${AZURE_ENV_NAME} -s ${SOURCE_CONTROL_PLATFORM}
```

---

## How to Configure

1. **Set the Project Name:**  
   Change the `name` field to match your project.

2. **Customize Hooks:**  
   - Edit the `preprovision` hook to run any setup commands before provisioning resources.
   - Adjust the shell, error handling, and interactivity as needed.
   - Use environment variables to pass configuration to your scripts.

3. **Use Environment Variables:**  
   The script checks for `SOURCE_CONTROL_PLATFORM` and sets a default if not present.  
   You can override this by setting the variable before running `azd`:
   ```bash
   export SOURCE_CONTROL_PLATFORM="adogit"
   azd up
   ```

4. **Run Setup Scripts:**  
   The hook runs `setup.sh` with the environment name and source control platform.  
   Ensure your script is executable and located in the project root.

---

## Full Example

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Azure/azure-dev/refs/heads/main/schemas/v1.0/azure.yaml.json

name: MyAwesomeProject

hooks:
  preprovision:
    shell: sh
    continueOnError: false
    interactive: true
    run: |
      #!/bin/bash
      set -e
      defaultPlatform="github"
      if [ -z "${SOURCE_CONTROL_PLATFORM}" ]; then
          export SOURCE_CONTROL_PLATFORM="${SOURCE_CONTROL_PLATFORM:-${defaultPlatform}}"
      fi
      ./setup.sh -e ${AZURE_ENV_NAME} -s ${SOURCE_CONTROL_PLATFORM}
```

---

## Additional Resources

- [Azure Dev CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/cli/)
- [Azure Dev CLI YAML Schema](https://github.com/Azure/azure-dev/tree/main/schemas)

---

This configuration enables automated, repeatable environment setup for Azure development projects using the Azure
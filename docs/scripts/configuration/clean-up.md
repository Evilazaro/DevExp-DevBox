# 🧹 cleanUp.ps1

> **Removes Azure resource groups for DevExp-DevBox environment**

---

## 📑 Table of Contents

- [🎯 Overview](#overview)
- [📊 Flow Visualization](#flow-visualization)
- [📝 Parameters](#parameters)
- [⚙️ Prerequisites](#prerequisites)
- [🗂️ Resource Groups Deleted](#resource-groups-deleted)
- [🔧 Functions Reference](#functions-reference)
- [📝 Usage Examples](#usage-examples)
- [⚠️ Error Handling](#error-handling)
- [🛠️ Troubleshooting](#troubleshooting)
- [🔒 Security Considerations](#security-considerations)
- [🔗 Related Scripts](#related-scripts)

---

## 🎯 Overview

This script deletes Azure resource groups and their associated deployments for the DevExp-DevBox infrastructure. It removes workload, connectivity, monitoring, security, and supporting resource groups based on a naming convention.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📊 Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([cleanUp.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph Main["Main Orchestration"]
        C["Remove-AllResourceGroups"]:::core
        D["Build resource group names"]:::core
    end
    
    subgraph RGLoop["Resource Group Deletion Loop"]
        E["For each resource group"]:::core
        F["Remove-AzureResourceGroup"]:::core
        F1[(az group exists)]:::external
        F2{RG exists?}:::decision
        F3[(az deployment group list)]:::external
        F4["Delete deployments"]:::core
        F5[(az group delete --no-wait)]:::external
    end
    
    subgraph Exit["Script Exit"]
        G{All succeeded?}:::decision
        H[\Deletions Initiated\]:::output
        I{{Partial Failure}}:::error
    end
    
    A --> B --> C --> D --> E
    E --> F --> F1 --> F2
    F2 -->|No| E
    F2 -->|Yes| F3 --> F4 --> F5 --> E
    E -->|All processed| G
    G -->|Yes| H
    G -->|No| I

    classDef entry fill:#2196F3,stroke:#1565C0,color:#fff
    classDef input fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef core fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef external fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef decision fill:#FFC107,stroke:#FFA000,color:#000
    classDef output fill:#2196F3,stroke:#1565C0,color:#fff
    classDef error fill:#F44336,stroke:#C62828,color:#fff
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Parameters

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `-EnvName` | `string` | No | `"demo"` | `ValidateNotNullOrEmpty` | Environment name for resource group naming |
| `-Location` | `string` | No | `"eastus2"` | `ValidateSet` | Azure region (eastus, eastus2, westus, westus2, westus3, northeurope, westeurope) |
| `-WorkloadName` | `string` | No | `"devexp"` | `ValidateNotNullOrEmpty` | Workload name prefix for resource groups |

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚙️ Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| Azure CLI (`az`) | Delete Azure resources | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **Azure**: Contributor or Owner on the subscription
- Permission to delete resource groups and deployments

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🗂️ Resource Groups Deleted

Based on the naming convention `{WorkloadName}-{type}-{EnvName}-{Location}-rg`:

| Resource Group Pattern | Purpose |
|------------------------|---------|
| `{workload}-workload-{env}-{location}-rg` | DevCenter and related resources |
| `{workload}-connectivity-{env}-{location}-rg` | VNets and network connections |
| `{workload}-monitoring-{env}-{location}-rg` | Log Analytics and monitoring |
| `{workload}-security-{env}-{location}-rg` | Key Vault and security resources |
| `NetworkWatcherRG` | Azure-managed network watcher |
| `Default-ActivityLogAlerts` | Default alert rules |
| `DefaultResourceGroup-WUS2` | Default Azure-created resources |

### Example Resource Groups (with defaults)

```
devexp-workload-demo-eastus2-rg
devexp-connectivity-demo-eastus2-rg
devexp-monitoring-demo-eastus2-rg
devexp-security-demo-eastus2-rg
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Functions Reference

### Function: `Remove-AzureResourceGroup`

**Purpose:** Deletes an Azure resource group and its deployments.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ResourceGroupName` | `string` | Yes | Name of the resource group to delete |

**Returns:** `[bool]` - `$true` if deletion initiated successfully, `$false` on error

**Behavior:**

1. Checks if resource group exists (`az group exists`)
2. If exists, lists all deployments in the group
3. Deletes each deployment first
4. Waits 10 seconds for deployment deletions
5. Initiates async resource group deletion (`--no-wait`)
6. Supports `-WhatIf` via `SupportsShouldProcess`

---

### Function: `Remove-AllResourceGroups`

**Purpose:** Removes all DevExp-DevBox related resource groups.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `WorkloadName` | `string` | Yes | Workload name prefix |
| `Environment` | `string` | Yes | Environment name |
| `Location` | `string` | Yes | Azure region |

**Returns:** `[bool]` - `$true` if all deletions initiated, `$false` otherwise

**Builds and deletes these resource groups:**

- `{WorkloadName}-workload-{Environment}-{Location}-rg`
- `{WorkloadName}-connectivity-{Environment}-{Location}-rg`
- `{WorkloadName}-monitoring-{Environment}-{Location}-rg`
- `{WorkloadName}-security-{Environment}-{Location}-rg`
- `NetworkWatcherRG`
- `Default-ActivityLogAlerts`
- `DefaultResourceGroup-WUS2`

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Usage Examples

### Default Cleanup

```powershell
.\cleanUp.ps1
```

Deletes resource groups for:

- Workload: `devexp`
- Environment: `demo`
- Location: `eastus2`

### Production Environment Cleanup

```powershell
.\cleanUp.ps1 -EnvName "prod" -Location "westus2"
```

### Custom Workload Name

```powershell
.\cleanUp.ps1 -WorkloadName "mycompany" -EnvName "dev" -Location "northeurope"
```

### Dry Run (WhatIf)

```powershell
.\cleanUp.ps1 -WhatIf
```

<details>
<summary>Expected Output</summary>

```
DevExp-DevBox Resource Cleanup
==============================
Starting cleanup of resource groups...
Environment: demo
Location: eastus2

Deleting deployment: initial-deployment
Deployment 'initial-deployment' deleted.
Deleting resource group: devexp-workload-demo-eastus2-rg (async)...
Resource group 'devexp-workload-demo-eastus2-rg' deletion initiated.
Resource group 'devexp-connectivity-demo-eastus2-rg' does not exist. Skipping.
...

All resource group deletions initiated successfully.
```

</details>

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚠️ Error Handling

### Error Action Preference

```powershell
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All deletions initiated successfully |
| `1` | One or more deletions failed |

### Asynchronous Deletion

Resource groups are deleted with `--no-wait` flag:

- Script returns immediately after initiating deletion
- Actual deletion continues in the background
- May take several minutes to complete

### Idempotency

The script is **idempotent**:

- Non-existent resource groups are skipped with message
- Safe to run multiple times
- No error if already deleted

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🛠️ Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Failed to check if resource group exists" | Not logged into Azure | Run `az login` |
| "Failed to initiate resource group deletion" | Resource locks present | Remove locks first |
| Deployment deletion fails | Deployment in progress | Wait and retry |
| Slow deletion | Large resources (Dev Boxes) | Allow more time |

### Monitor Deletion Progress

```powershell
# Check if resource group still exists
az group exists --name "devexp-workload-demo-eastus2-rg"

# List resource groups matching pattern
az group list --query "[?contains(name, 'devexp')]" --output table
```

### Force Delete Locked Resources

```powershell
# Remove lock first
az lock delete --name {lock-name} --resource-group {rg-name}
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔒 Security Considerations

### Destructive Operation

- This script **permanently deletes** Azure resources
- Deleted resources cannot be recovered
- All data in the resource groups will be lost

### Before Execution Checklist

- [ ] Verify correct environment and location parameters
- [ ] Confirm no production workloads in target resource groups
- [ ] Back up any important data or configurations
- [ ] Consider using `-WhatIf` first

### Resource Locks

Azure resource locks can prevent accidental deletion:

- Remove locks before running cleanup
- Or use Azure portal to delete locked resources

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `cleanSetUp.ps1` | Full environment cleanup orchestrator | [../clean-setup.md](../clean-setup.md) |
| `setUp.ps1` | Environment setup (opposite operation) | [../setup.md](../setup.md) |

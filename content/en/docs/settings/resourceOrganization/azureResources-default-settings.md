---
title: Resources Organization Documentation
tags: 
 - devbox
 - resources
 - subnet
description: Resources Organization Documentation
---

# Microsoft Dev Box Accelerator: Resources Organization Documentation

## Overview

This documentation details the resource organization structure for the Microsoft Dev Box Accelerator. The configuration defines a comprehensive resource group strategy aligned with Azure Landing Zone principles, segregating resources based on their functional purpose to improve manageability, security, and governance.

## Default Settings

```yaml
# yaml-language-server: $schema=./azureResources.shema.json
#
# Microsoft Dev Box Accelerator: Resource Groups Configuration
# =======================================================
#
# Purpose: Defines the resource group organization structure for Microsoft Dev Box Accelerator environments.
# This configuration aligns with Azure Landing Zone principles by segregating resources
# based on their functional purpose (workload, security, monitoring, connectivity).
#
# References:
# - Azure Landing Zones: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/
# - Azure Resource Groups: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal

# Workload Resource Group
# -----------------------
# Purpose: Contains the primary Dev Box workload resources including:
# - Dev Center resources
# - Dev Box definitions
# - Dev Box pools
# - Project resources
#
# Best practice: Separate application workloads from infrastructure components
# to enable independent scaling, access control, and lifecycle management.
workload:
  # Determines whether to create this resource group or use existing
  create: true
  
  # Resource group name
  # Best practice: Use a consistent naming convention such as:
  # [project]-[purpose]-[environment]-rg
  name: devexp-workload
  
  # Brief description of the resource group purpose
  # Consider replacing "prodExp" with more descriptive text like:
  # "Dev Box primary workload resources"
  description: prodExp
  
  # Resource tags for governance and organization
  # Best practice: Apply consistent tags across all resources
  # for effective resource management and cost allocation
  tags:
    environment: dev           # Deployment environment (dev, test, prod)
    division: Platforms        # Business division responsible for the resource
    team: DevExP              # Team owning the resource
    project: Contoso-DevExp-DevBox  # Project name
    costCenter: IT            # Financial allocation center
    owner: Contoso            # Resource owner
    landingZone: Workload     # Landing zone classification
    resources: ResourceGroup  # Resource type

# Security Resource Group
# ----------------------
# Purpose: Contains security-related resources including:
# - Key Vaults for secret management
# - Microsoft Defender for Cloud configurations
# - Network Security Groups
# - Private endpoints
#
# Best practice: Isolate security resources to apply stricter access controls
# and enable separate monitoring/auditing of security components.
security:
  create: true
  name: devexp-security
  description: prodExp
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: Workload
    resources: ResourceGroup

# Monitoring Resource Group
# ------------------------
# Purpose: Contains monitoring and observability resources including:
# - Log Analytics workspaces
# - Application Insights components
# - Azure Monitor alerts and action groups
# - Dashboard and reporting resources
#
# Best practice: Centralize monitoring resources to provide a unified view
# of operational health and simplify diagnostic activities.
monitoring:
  create: true
  name: devexp-monitoring
  description: prodExp
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: Workload
    resources: ResourceGroup

# Connectivity Resource Group
# --------------------------
# Purpose: Contains networking and connectivity resources including:
# - Virtual Networks and Subnets
# - Network Security Groups
# - Virtual Network Peerings
# - Private DNS Zones
# - Azure Bastion (if applicable)
#
# Best practice: Segregate network infrastructure to enable specialized management
# by networking teams and facilitate network-wide security policies.
connectivity:
  create: true
  name: devexp-connectivity
  description: prodExp
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: Workload
    resources: ResourceGroup
```

## References

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Cloud Adoption Framework - Naming and Tagging Strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft Dev Box Accelerator GitHub](https://github.com/Evilazaro/DevExp-DevBox/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)

---

*This documentation is part of the Microsoft Dev Box Accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*
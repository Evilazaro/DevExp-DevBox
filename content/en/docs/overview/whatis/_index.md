---
title: Dev Box landing zone accelerator
description: What is Dev Box landing zone accelerator?
weight: 3
---

{{% pageinfo %}}
The **Dev Box landing zone accelerator** is an open-source, reference implementation designed to help you quickly establish a landing zone subscription optimized for Microsoft Dev Box deployments. Built on the principles and best practices of the [Azure Cloud Adoption Framework (CAF) enterprise-scale landing zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/enterprise-scale), it provides a strategic design path and a target technical state that:

- Establishes foundational services (network, identity, security, governance) required for a scalable Dev Box environment.
- Aligns to CAF guidance for subscription structure, management groups, policy, and role-based access control (RBAC).
- Is fully modular, parameterized, and ready to be adapted to your organization’s existing landing zone or to provision new platform services from scratch.
- Is open source—feel free to fork, extend, or customize the Bicep modules, policies, and scripts to meet your unique requirements.
{{% /pageinfo %}}

## What the Microsoft Dev Box Accelerator Landing Zone Provides

1. **Architectural Approach & Reference Implementation**  
   A set of Bicep modules, and scripts that together prepare a landing zone subscription for production-ready Microsoft Dev Box workloads. This includes:
   - **Networking**: Virtual network, subnets (management, Dev Box), and optional peering to hub networks.  
   - **Identity & Access**: Integration with Azure AD, service principals, managed identities, and RBAC assignments.  
   - **Security & Governance**: Policy assignments (tagging, security baseline, resource consistency), Azure Monitor and Log Analytics integration.  
   - **Platform Services**: Key Vault, and optional DevCenter host pools.

2. **Cloud Adoption Framework Alignment**  
   All artifacts adhere to the CAF’s enterprise-scale landing zone patterns:
   - **Management Group Hierarchy** for clear separation of environments (e.g., Connectivity, Monitoring, Security, and Workload).    
   - **Modularity** so you can pick and choose how the foundational services will be deployed.

3. **Enterprise-Scale Design Principles**  
   - **Scalability**: Built to support hundreds of developer seats and multiple Dev Box SKUs.    
   - **Security**: Zero-trust networking, least-privilege access, and continuous compliance monitoring.  
   - **Cost Management**: Tagging, budget alerts, and automated shutdown/startup of idle Dev Boxes.

## Design Areas

When implementing a scalable Microsoft Dev Box landing zone, consider the following design areas:

| Design Area                | Considerations                                                                                                           |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------|
| **Subscription Topology**  | Placement under a dedicated “DevBox” management group; isolation from production workloads; environment-dependent naming. |
| **Resource Organization**  | Resource group structure (e.g., `platform-rg`, `network-rg`, `devbox-rg`); consistent naming & tagging policies.        |
| **Networking**             | Hub-and-spoke or standalone VNet; subnet segmentation; Azure Firewall or NVA integration; optional VPN/ExpressRoute.     |
| **Identity & Access**      | Azure AD security groups for developers; managed identities for automation; service principal for DevCenter integration. |
| **Policies & Governance**  | Policy definitions for allowed SKUs, location constraints, storage encryption, and tagging enforcement.                 |
| **Platform Services**      | Key Vault for secrets; Log Analytics workspace for telemetry; Automation Account for scheduled tasks.                    |
| **Dev Center Integration** | Configuration of Dev Center environments and host pools; assignment of Dev Center roles via RBAC.                        |

> **Adaptation Paths**  
> - **Greenfield**: Deploy the accelerator’s Bicep modules to create platform foundational services, then launch your Dev Box environment.  
> - **Brownfield**: Import existing landing zone services by disabling overlapping modules and parameterizing connections (e.g., pointing to an existing VNet, Subnet, Resource Group or Key Vault).

Learn more how to configure the Accelerator in the [Configure Resources](../../configureResources/) session.
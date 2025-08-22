# Build

[![Accelerator CD](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/azure-dev.yml/badge.svg)](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/azure-dev.yml)
[![Documentation CI/CD](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/hugo.yml/badge.svg)](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/hugo.yml)

# Overview
The [**Dev Box accelerator**](https://evilazaro.github.io/DevExp-DevBox/) is an open-source, reference implementation designed to help you quickly establish a landing zone subscription optimized for Microsoft Dev Box deployments. Built on the principles and best practices of the [**Azure Cloud Adoption Framework (CAF) enterprise-scale landing zones**](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/enterprise-scale), it provides a strategic design path and a target technical state that:

- Establishes foundational services (network, monitoring, security, and workload) required for a secure, scalable, and multi-tenant Dev Box environment.
- Aligns to CAF guidance for subscription structure, resource groups, and role-based access control (RBAC).
- Is fully modular, parameterized, and ready to be adapted to your organization’s existing landing zone or to provision new platform services from scratch.
- Is open source—feel free to fork, extend, or customize the Bicep modules, policies, and scripts to meet your unique requirements.

## Resources Visualization

![Resources Visualization](https://evilazaro.github.io/DevExp-DevBox/docs/overview/whatis/mainbicepvisualization.png)

## What the Microsoft Dev Box accelerator Provides

The Microsoft Dev Box Accelerator delivers a comprehensive set of Bicep modules, automation scripts, and **YAML configuration files with accompanying JSON schema definitions**, designed to streamline the deployment of a production-ready Microsoft Dev Box landing zone. These artifacts empower infrastructure professionals with a **configuration-as-code** approach, enabling repeatable, scalable, and policy-compliant environments.

### Key Components

- **Networking**: Virtual networks, subnets, network connections and optional hub connectivity.
- **Identity & Access**: Microsoft Entra integration, service principals, managed identities, and RBAC assignments.
- **Security & Governance**: Policy assignments (tagging, security baseline, resource consistency), Azure Monitor and Log Analytics integration.
- **Platform Services**: DevCenter, Projects, and supporting components.

## Cloud Adoption Framework Alignment

All artifacts align with CAF’s enterprise-scale landing zone patterns:

- **Management Group Hierarchy**: Clear separation of concerns (Connectivity, Monitoring, Security, Workload).
- **Modularity**: Deploy only the foundational services you need.

## Enterprise-Scale Design Principles

- **Scalability**: Supports hundreds of developers and multiple Dev Box SKUs.
- **Security**: Zero-trust networking, least-privilege access, continuous monitoring, and compliance.
- **Cost Management**: Tagging, budget alerts, and automated Dev Box lifecycle management.

## Design Areas

When implementing a scalable Microsoft Dev Box landing zone, consider the following design areas:

| Design Area                | Considerations                                                                                                           |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------|
| **Subscription Topology**  | Placement under a dedicated **“Dev Box”** subscription; isolation from production workloads; environment-dependent naming. |
| **Resource Organization**  | Resource group structure (e.g., `connectivity-rg`, `monitoring-rg`, `security-rg`, and `workload-rg`); consistent naming & tagging policies.        |
| **Networking**             | Hub-and-spoke or standalone VNet; subnet segmentation; Azure Firewall or NVA integration; optional VPN/ExpressRoute.     |
| **Identity & Access**      | Microsoft Entra security groups for platform engineering teams, dev team leads, and developers; managed identities for automation, and DevCenter integration. |                 |
| **Security & Governance**  | Key Vault for secrets; Log Analytics workspace for logs, and telemetry.                    |
| **Platform Services** | Configuration of Dev Center, Custom Tasks Catalogs, Networking Connections, Projects, Environments and Image Definitions, and environments types; assignment of Dev Center roles via RBAC.                        |

## Journey Paths  
> - **Greenfield**: Deploy the accelerator’s Bicep modules to create platform foundational services, then launch your Dev Box environment.  
> - **Brownfield**: Import existing landing zone services by disabling and parameterizing connections (e.g., pointing to an existing VNet, Subnet, Resource Group or Key Vault).

**Learn more** how to configure the Accelerator in the [Accelerator Configuration](https://evilazaro.github.io/DevExp-DevBox/docs/configureresources/) session.

## Release Strategy

## Overview

The Dev Box landing zone accelerator uses a **branch-based semantic release strategy** with intelligent overflow handling and conditional versioning rules. This approach ensures consistent, predictable releases while maintaining development flexibility across different branch types. [Learn more...](RELEASE_STRATEGY.md)

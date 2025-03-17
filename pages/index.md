---
layout: page
title: Overview
permalink: /
---

# Contoso Dev Box Use Case

Welcome to the Contoso Dev Box repository! This project showcases how Contoso, a fictitious company with developers located worldwide, leverages Microsoft Dev Box to streamline its engineer onboarding and deployment environment automation processes.

## Overview

Contoso aims to enhance its engineering efficiency by adopting Microsoft Dev Box. This repository demonstrates how Contoso designed and deployed its solution, enabling remote engineers to quickly and effectively set up their development environments.

## Key Benefits

- **Streamlined Onboarding**: New engineers can get started quickly with pre-configured development environments.
- **Automated Deployment**: Simplifies the process of setting up and managing deployment environments.
- **Global Accessibility**: Ensures that developers from any location can access the necessary tools and resources.
- **Platform Engineering Capabilities**: Platform engineers can create dev box pools, manage security settings, network configurations, and organizational policies to ensure secure access to resources [here](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box).

Explore the repository to learn more about how Contoso utilizes Microsoft Dev Box to achieve these goals.

# Contoso Dev Box Solution Architecture

The Contoso Dev Box solution is designed to streamline the Engineer onboarding process for various projects using Microsoft Dev Box. Below is a detailed step-by-step description of the solution architecture, accompanied by the provided Solution Architecture Picture.

![Contoso Solution Architecture](../assets/img/ContosoDevBox.png)

## Step-by-Step Workflow

1. **Contoso Engineering Teams (Developers, QA, SRE, Operations)**
   - Engineers from different teams such as Developers, QA, SRE (Site Reliability Engineering), and Operations are depicted at the top left of the diagram.
   - These engineers need access to development environments to work on their respective projects.

2. **Azure Environment**
   - The entire solution is hosted within Azure.

3. **Contoso Product Team**
   - There are multiple instances of Contoso Product Teams shown in separate boxes within Azure.
   - Each product team has its own set of resources including:
     - **PR Pipelines/Repos**: These are repositories and pipelines for managing code and continuous integration/continuous deployment (CI/CD) processes.
     - **Virtual Machines**: Virtual machines that provide isolated development environments for engineers.
     - **Dev Boxes**: Specific development environments tailored for each engineer's needs.

4. **Contoso Dev Box Service**
   - This service acts as a central hub for managing all Dev Boxes across different product teams.
   - Key components include:
     - **Projects**: Different projects that engineers are working on.
     - **Dev box definition**: Templates or configurations defining what a Dev Box should contain.
     - **Dev box pool**: A collection of available Dev Boxes ready to be assigned to engineers.

5. **Connections Layer (Onboarding Layer)**
   - This layer facilitates connections between various components:
     - Engineers connect through this layer to access their assigned Dev Boxes based on project requirements.

6. **Additional Azure Services**
   - Several additional services support the overall infrastructure:
     - **Azure Active Directory (AAD)**: Manages user identities and access control.
     - **Billing & Cost Management**: Tracks usage and costs associated with running virtual machines and other resources.
     - **Security Center**: Ensures security compliance and monitors potential threats within the environment.
     - **Automation Accounts**: Automates repetitive tasks such as provisioning new Dev Boxes or scaling resources up/down based on demand.

## Workflow Summary
1. Engineers from various teams request access to development environments through Contoso's onboarding process facilitated by Azure.
2. The Contoso Dev Box Service manages the allocation and configuration of Dev Boxes based on project requirements.
3. Engineers connect to their assigned Dev Boxes through the Connections Layer.
4. Additional Azure services ensure security, cost management, and automation within the environment.
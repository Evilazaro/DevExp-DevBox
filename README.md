# DevExp-DevBox

A comprehensive Azure Developer Experience solution leveraging Microsoft Dev Box
for cloud-based developer workstations.

[![CI](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/ci.yml/badge.svg)](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/ci.yml)
[![Deploy](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/deploy.yml/badge.svg)](https://github.com/Evilazaro/DevExp-DevBox/actions/workflows/deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Overview

This repository provides Infrastructure as Code (IaC) and automation scripts to
deploy and manage a complete Azure Dev Box environment. It enables organizations
to provision cloud-hosted developer workstations with pre-configured tools and
settings.

## 🏗️ Architecture

The solution follows Azure's Cloud Adoption Framework and Well-Architected
Framework principles, organized into the following components:

| Component        | Description                                       |
| ---------------- | ------------------------------------------------- |
| **Connectivity** | Network infrastructure and connectivity resources |
| **Identity**     | Identity and access management configuration      |
| **Management**   | Dev Center, projects, and pools management        |
| **Security**     | Security policies and configurations              |
| **Workload**     | Application workloads and services                |

For detailed architecture documentation, see the
[docs/architecture](docs/architecture) folder:

- [Application Architecture](docs/architecture/Application.md)
- [Business Architecture](docs/architecture/Business.md)
- [Data Architecture](docs/architecture/Data.md)
- [Technology Architecture](docs/architecture/Technology.md)

## 📁 Project Structure

```

├── .configuration/ # Configuration files for Dev Center and setup │ ├──
devcenter/ # Dev Center workload definitions │ ├── powershell/ # PowerShell
cleanup scripts │ └── setup/ # Setup configurations ├── .github/ # GitHub
Actions workflows │ ├── actions/ # Reusable GitHub Actions │ └── workflows/ #
CI/CD pipelines ├── docs/ # Documentation │ └── architecture/ # Architecture
decision records ├── infra/ # Infrastructure as Code (Bicep) │ ├── main.bicep #
Main Bicep template │ ├── main.parameters.json # Parameters file │ └──
settings/ # Resource organization settings └── src/ # Source code modules ├──
connectivity/ # Network resources ├── identity/ # Identity resources ├──
management/ # Management resources ├── security/ # Security resources └──
workload/ # Workload resources

```

## 🚀 Getting Started

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (v2.50+)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [PowerShell 7+](https://docs.microsoft.com/powershell/scripting/install/installing-powershell)
  (for Windows setup)
- [Bash](https://www.gnu.org/software/bash/) (for Linux/macOS setup)
- Azure subscription with appropriate permissions

### Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/Evilazaro/DevExp-DevBox.git
   cd DevExp-DevBox
   ```

2. **Authenticate with Azure**

   ```bash
   azd auth login
   az login
   ```

3. **Run the setup script**

   **Windows (PowerShell):**

   ```powershell
   ./setUp.ps1
   ```

   **Linux/macOS (Bash):**

   ```bash
   ./setUp.sh
   ```

4. **Deploy the infrastructure**
   ```bash
   azd up
   ```

### Cleanup

To remove all deployed resources:

**Windows (PowerShell):**

```powershell
./cleanSetUp.ps1
```

Or use the configuration script:

```powershell
./.configuration/powershell/cleanUp.ps1
```

## 🔧 Configuration

### Azure Developer CLI

This project uses azure.yaml for Azure Developer CLI configuration. Key settings
can be customized in:

- azure.yaml - Main azd configuration
- main.parameters.json - Bicep parameters

### Dev Center Configuration

Dev Center workload definitions are located in:

- workloads

## 🔄 CI/CD

This project includes GitHub Actions workflows for continuous integration and
deployment:

| Workflow    | Description                     |
| ----------- | ------------------------------- |
| ci.yml      | Continuous Integration pipeline |
| deploy.yml  | Deployment pipeline             |
| release.yml | Release management              |

## 📖 Documentation

- Application Architecture - Application design patterns
- Business Architecture - Business requirements and goals
- Data Architecture - Data management strategy
- Technology Architecture - Technology stack decisions

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for
details.

## 📞 Support

For issues and feature requests, please
[open an issue](https://github.com/Evilazaro/DevExp-DevBox/issues) on GitHub.

---

**Built with ❤️ using Azure Dev Box and Azure Developer CLI**

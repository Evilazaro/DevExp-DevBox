---
title: Common DSC Configuration for .NET Engineers Sample
description: >
    Dev Box Image Definitions
weight: 9
---


# PowerShell DSC Configuration Documentation

## Overview

This document provides a detailed explanation of the PowerShell Desired State Configuration (DSC) YAML file: **common-config.dsc.yaml**. 

The configuration file is part of the Microsoft Dev Box landing zone accelerator and is designed to provision a standardized development environment. It includes components for development storage, source control, development runtimes, and tools setup.

This documentation aims to break down each resource component, explaining its purpose and usage in the configuration.

## Table of Contents
- [DevDrive1](#devdrive1)
- [Git.Git](#gitgit)
- [GitHub.cli](#githubcli)
- [Microsoft.DotNet.SDK.9](#microsoftdotnetsdk9)
- [Microsoft.DotNet.Runtime.9](#microsoftdotnetruntime9)
- [OpenJS.NodeJS](#openjsnodejs)
- [Microsoft.VisualStudioCode](#microsoftvisualstudiocode)


## DevDrive1
### YAML Configuration
```yaml
resource: Disk
id: DevDrive1
directives:
  module: StorageDsc
  allowPrerelease: true
  description: Configure Dev Drive with ReFS format
settings:
  DiskId: '0'
  DiskIdType: Number
  DriveLetter: Z
  FSLabel: Dev Drive 1
  DevDrive: true
  AllowDestructive: true
  FSFormat: ReFS
  Size: 50Gb

```

### Explanation
**Configure Dev Drive with ReFS format**

This component defines a `Disk` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## Git.Git
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: Git.Git
directives:
  allowPrerelease: true
  description: Install Git version control system
settings:
  id: Git.Git

```

### Explanation
**Install Git version control system**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## GitHub.cli
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: GitHub.cli
directives:
  allowPrerelease: true
  description: Install GitHub command-line interface
settings:
  id: GitHub.cli
dependsOn:
- Git.Git

```

### Explanation
**Install GitHub command-line interface**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## Microsoft.DotNet.SDK.9
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: Microsoft.DotNet.SDK.9
directives:
  allowPrerelease: true
  description: Install .NET 9 SDK for application development
settings:
  id: Microsoft.DotNet.SDK.9

```

### Explanation
**Install .NET 9 SDK for application development**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## Microsoft.DotNet.Runtime.9
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: Microsoft.DotNet.Runtime.9
directives:
  allowPrerelease: true
  description: Install .NET 9 Runtime
settings:
  id: Microsoft.DotNet.Runtime.9
dependsOn:
- Microsoft.DotNet.SDK.9

```

### Explanation
**Install .NET 9 Runtime**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## OpenJS.NodeJS
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: OpenJS.NodeJS
directives:
  allowPrerelease: true
  description: Install Node.js JavaScript runtime
settings:
  id: OpenJS.NodeJS

```

### Explanation
**Install Node.js JavaScript runtime**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)


## Microsoft.VisualStudioCode
### YAML Configuration
```yaml
resource: Microsoft.WinGet.DSC/WinGetPackage
id: Microsoft.VisualStudioCode
directives:
  allowPrerelease: true
  description: Install Visual Studio Code editor
settings:
  id: Microsoft.VisualStudioCode

```

### Explanation
**Install Visual Studio Code editor**

This component defines a `Microsoft.WinGet.DSC/WinGetPackage` configuration used to provision and manage a system resource.

### Official Documentation Link
[Official Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)

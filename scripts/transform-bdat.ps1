
<#
.SYNOPSIS
  Transform business-architecture.md per BDAT refactoring instructions.
  - Removes Source, Evidence, Maturity, Confidence from all tables
  - Adds Quick TOC
  - Adds emojis to all section headings
  - Adds emojis to all table headers
  - Adds Section 3 Principle Hierarchy diagram (comprehensive quality)
#>

$path = "z:\plat\docs\architecture\business-architecture.md"
$lines = Get-Content $path -Encoding UTF8

# ─────────────────────────────────────────────────────────────────────────────
# PASS 1: Line-by-line transforms with section context
# ─────────────────────────────────────────────────────────────────────────────
$section = 0          # 1=ExecSummary, 2=Landscape, 3=Principles, 4=Baseline, 5=Catalog, 8=Dependencies
$s8TableState = ""    # track which Section 8 table we're in: "capability" | "valuestream" | "rules" | ""

$newLines = [System.Collections.Generic.List[string]]::new()

foreach ($line in $lines) {

    # ── Section detection (must run before transforms) ──────────────────────────
    if ($line -match "^## 1\.") { $section = 1; $s8TableState = "" }
    elseif ($line -match "^## 2\.") { $section = 2; $s8TableState = "" }
    elseif ($line -match "^## 3\.") { $section = 3; $s8TableState = "" }
    elseif ($line -match "^## 4\.") { $section = 4; $s8TableState = "" }
    elseif ($line -match "^## 5\.") { $section = 5; $s8TableState = "" }
    elseif ($line -match "^## 8\.") { $section = 8; $s8TableState = "" }

    # ── Section 8 table state detection ─────────────────────────────────────────
    if ($section -eq 8 -and $line -match "^\| Business Capability\b") {
        $s8TableState = "capability"
    }
    elseif ($section -eq 8 -and $line -match "^\| Value Stream\b") {
        $s8TableState = "valuestream"
    }
    elseif ($section -eq 8 -and $line -match "^\| Business Rule\b") {
        $s8TableState = "rules"
    }
    elseif ($section -eq 8 -and $line -notmatch "^\|") {
        $s8TableState = ""
    }

    # ── SKIP: Section 3 Evidence/Confidence attribute rows ───────────────────────
    if ($section -eq 3 -and $line -match "^\| \*\*(Evidence|Confidence)\*\*") {
        continue
    }

    # ── SKIP: Section 5 Source/Confidence/Maturity attribute rows ───────────────
    if ($section -eq 5 -and $line -match "^\| \*\*(Source|Confidence|Maturity)\*\*([^|]*)\|") {
        continue
    }

    # ── Section 2 table transforms (remove last 3 of 5 columns) ─────────────────
    if ($section -eq 2 -and $line -match "^\|") {

        if ($line -match "^\| Name ") {
            # Replace header row (will be given proper emoji below)
            $line = "| 🏷️ Name | 📝 Description |"
        }
        elseif ($line -match "^\| -+\s*\| -+\s*\| -+\s*\| -+\s*\| -+\s*\|") {
            # 5-column separator -> 2-column
            $line = "| --- | --- |"
        }
        elseif ($line -match "^\|([^|]+)\|([^|]+)\|[^|]+\|[^|]+\|[^|]+\|") {
            # 5-column data row -> keep first 2 cols only
            $line = "|$($matches[1])|$($matches[2])|"
        }
    }

    # ── Section 8 table transforms (remove Source Reference col) ─────────────────
    if ($section -eq 8 -and $s8TableState -eq "capability" -and $line -match "^\|") {
        if ($line -match "^\| Business Capability\b") {
            $line = "| ⚙️ Business Capability | 🔧 Application Module | 📡 Integration Type |"
        }
        elseif ($line -match "^\| -+\s*\| -+\s*\| -+\s*\| -+\s*\|") {
            $line = "| --- | --- | --- |"
        }
        elseif ($line -match "^\|([^|]+)\|([^|]+)\|[^|]+\|([^|]+)\|") {
            $line = "|$($matches[1])|$($matches[2])|$($matches[3])|"
        }
    }

    if ($section -eq 8 -and $s8TableState -eq "valuestream" -and $line -match "^\|") {
        if ($line -match "^\| Value Stream\b") {
            $line = "| 🌊 Value Stream | 🔄 Supporting Process | 🛎️ Business Services | 🖥️ Technology Entry Point |"
        }
        elseif ($line -match "^\| -+\s*\| -+\s*\| -+\s*\| -+\s*\|") {
            $line = "| --- | --- | --- | --- |"
        }
        # data rows unchanged (no Source column in this table)
    }

    if ($section -eq 8 -and $s8TableState -eq "rules" -and $line -match "^\|") {
        if ($line -match "^\| Business Rule\b") {
            $line = "| 📋 Business Rule | 🔧 Technology Enforcement Mechanism |"
        }
        elseif ($line -match "^\| -+\s*\| -+\s*\| -+\s*\|") {
            $line = "| --- | --- |"
        }
        elseif ($line -match "^\|([^|]+)\|([^|]+)\|[^|]+\|") {
            $line = "|$($matches[1])|$($matches[2])|"
        }
    }

    # ── Section 8 standalone attribute tables (non-capability/rules) ────────────
    # Value Stream-to-Technology: handle data rows (4 cols, no removal needed)

    $newLines.Add($line)
}

# ─────────────────────────────────────────────────────────────────────────────
# PASS 2: String-level replacements on joined content
# ─────────────────────────────────────────────────────────────────────────────
$content = $newLines -join "`n"

# ── Section 2 subsection heading emojis (table headers differentiated) ────────
$content = $content -replace "### 2\.1 Business Strategy \(", "### 2.1 🎯 Business Strategy ("
$content = $content -replace "### 2\.2 Business Capabilities \(", "### 2.2 ⚙️ Business Capabilities ("
$content = $content -replace "### 2\.3 Value Streams \(", "### 2.3 🌊 Value Streams ("
$content = $content -replace "### 2\.4 Business Processes \(", "### 2.4 🔄 Business Processes ("
$content = $content -replace "### 2\.5 Business Services \(", "### 2.5 🛎️ Business Services ("
$content = $content -replace "### 2\.6 Business Functions \(", "### 2.6 🏢 Business Functions ("
$content = $content -replace "### 2\.7 Business Roles & Actors \(", "### 2.7 👤 Business Roles & Actors ("
$content = $content -replace "### 2\.8 Business Rules \(", "### 2.8 📋 Business Rules ("
$content = $content -replace "### 2\.9 Business Events \(", "### 2.9 ⚡ Business Events ("
$content = $content -replace "### 2\.10 Business Objects/Entities \(", "### 2.10 📦 Business Objects/Entities ("
$content = $content -replace "### 2\.11 KPIs & Metrics \(", "### 2.11 📈 KPIs & Metrics ("

# ── Section 3 subsection heading emojis ──────────────────────────────────────
$content = $content -replace "### 3\.1 Capability-Driven Design", "### 3.1 ⚙️ Capability-Driven Design"
$content = $content -replace "### 3\.2 Configuration-as-Code First", "### 3.2 📋 Configuration-as-Code First"
$content = $content -replace "### 3\.3 Least-Privilege Access", "### 3.3 🔒 Least-Privilege Access"
$content = $content -replace "### 3\.4 Observability-by-Default", "### 3.4 📡 Observability-by-Default"
$content = $content -replace "### 3\.5 Documentation-as-Code", "### 3.5 📝 Documentation-as-Code"
$content = $content -replace "### 3\.6 Idempotent Operations", "### 3.6 🔁 Idempotent Operations"

# ── Section 5 subsection heading emojis ──────────────────────────────────────
$content = $content -replace "### 5\.1 Business Strategy Specifications", "### 5.1 🎯 Business Strategy Specifications"
$content = $content -replace "### 5\.2 Business Capabilities Specifications", "### 5.2 ⚙️ Business Capabilities Specifications"
$content = $content -replace "### 5\.3 Value Streams Specifications", "### 5.3 🌊 Value Streams Specifications"
$content = $content -replace "### 5\.4 Business Processes Specifications", "### 5.4 🔄 Business Processes Specifications"
$content = $content -replace "### 5\.5 Business Services Specifications", "### 5.5 🛎️ Business Services Specifications"
$content = $content -replace "### 5\.6 Business Functions Specifications", "### 5.6 🏢 Business Functions Specifications"
$content = $content -replace "### 5\.7 Business Roles & Actors Specifications", "### 5.7 👤 Business Roles & Actors Specifications"
$content = $content -replace "### 5\.8 Business Rules Specifications", "### 5.8 📋 Business Rules Specifications"
$content = $content -replace "### 5\.9 Business Events Specifications", "### 5.9 ⚡ Business Events Specifications"
$content = $content -replace "### 5\.10 Business Objects/Entities Specifications", "### 5.10 📦 Business Objects/Entities Specifications"
$content = $content -replace "### 5\.11 KPIs & Metrics Specifications", "### 5.11 📈 KPIs & Metrics Specifications"

# ── Section 5 component detail heading emojis (####) ─────────────────────────
$content = $content -replace "#### 5\.1\.1 Platform Engineering Accelerator Strategy", "#### 5.1.1 🎯 Platform Engineering Accelerator Strategy"
$content = $content -replace "#### 5\.2\.1 Automated Infrastructure Provisioning", "#### 5.2.1 ⚙️ Automated Infrastructure Provisioning"
$content = $content -replace "#### 5\.2\.2 Configuration-as-Code Management", "#### 5.2.2 📋 Configuration-as-Code Management"
$content = $content -replace "#### 5\.2\.3 Security & Secrets Management", "#### 5.2.3 🔒 Security & Secrets Management"
$content = $content -replace "#### 5\.2\.4 Observability Platform", "#### 5.2.4 📊 Observability Platform"
$content = $content -replace "#### 5\.2\.5 Developer Self-Service Onboarding", "#### 5.2.5 👤 Developer Self-Service Onboarding"
$content = $content -replace "#### 5\.2\.6 Catalog & Asset Management", "#### 5.2.6 📚 Catalog & Asset Management"
$content = $content -replace "#### 5\.2\.7 Environment Lifecycle Management", "#### 5.2.7 🌍 Environment Lifecycle Management"
$content = $content -replace "#### 5\.3\.1 Developer Onboarding Value Stream", "#### 5.3.1 🌊 Developer Onboarding Value Stream"
$content = $content -replace "#### 5\.3\.2 Platform Provisioning Value Stream", "#### 5.3.2 🚀 Platform Provisioning Value Stream"
$content = $content -replace "#### 5\.4\.1 Infrastructure Provisioning Process", "#### 5.4.1 🔄 Infrastructure Provisioning Process"
$content = $content -replace "#### 5\.4\.2 Platform Contribution Process", "#### 5.4.2 🤝 Platform Contribution Process"
$content = $content -replace "#### 5\.5\.1 Dev Box Accelerator Service", "#### 5.5.1 🚀 Dev Box Accelerator Service"
$content = $content -replace "#### 5\.5\.2 Environment Management Service", "#### 5.5.2 🌍 Environment Management Service"
$content = $content -replace "#### 5\.5\.3 Catalog Management Service", "#### 5.5.3 📚 Catalog Management Service"
$content = $content -replace "#### 5\.6\.1 Platform Engineering Function", "#### 5.6.1 🏢 Platform Engineering Function"
$content = $content -replace "#### 5\.6\.2 Infrastructure Automation Function", "#### 5.6.2 ⚙️ Infrastructure Automation Function"
$content = $content -replace "#### 5\.6\.3 Documentation & Governance Function", "#### 5.6.3 📝 Documentation & Governance Function"
$content = $content -replace "#### 5\.7\.1 Platform Engineer", "#### 5.7.1 🧑‍💻 Platform Engineer"
$content = $content -replace "#### 5\.7\.2 Dev Manager", "#### 5.7.2 👔 Dev Manager"
$content = $content -replace "#### 5\.7\.3 Backend Developer", "#### 5.7.3 💻 Backend Developer"
$content = $content -replace "#### 5\.7\.4 Frontend Developer", "#### 5.7.4 🖥️ Frontend Developer"
$content = $content -replace "#### 5\.7\.5 eShop Engineers", "#### 5.7.5 👥 eShop Engineers"
$content = $content -replace "#### 5\.7\.6 Security & Compliance Officer", "#### 5.7.6 🛡️ Security & Compliance Officer"
$content = $content -replace "#### 5\.8\.1 Issue Labeling Rule", "#### 5.8.1 🏷️ Issue Labeling Rule"
$content = $content -replace "#### 5\.8\.2 Parameterization Rule", "#### 5.8.2 🔧 Parameterization Rule"
$content = $content -replace "#### 5\.8\.3 Docs-as-Code Rule", "#### 5.8.3 📝 Docs-as-Code Rule"
$content = $content -replace "#### 5\.8\.4 Least-Privilege RBAC Rule", "#### 5.8.4 🔒 Least-Privilege RBAC Rule"
$content = $content -replace "#### 5\.8\.5 Security Governance Rule", "#### 5.8.5 🛡️ Security Governance Rule"
$content = $content -replace "#### 5\.8\.6 Idempotency Rule", "#### 5.8.6 🔁 Idempotency Rule"
$content = $content -replace "#### 5\.9\.1 Provisioning Requested", "#### 5.9.1 🚀 Provisioning Requested"
$content = $content -replace "#### 5\.9\.2 Pre-Provision Validation", "#### 5.9.2 🔍 Pre-Provision Validation"
$content = $content -replace "#### 5\.9\.3 PR Merge Event", "#### 5.9.3 🔀 PR Merge Event"
$content = $content -replace "#### 5\.9\.4 Epic Completion Event", "#### 5.9.4 🏆 Epic Completion Event"
$content = $content -replace "#### 5\.9\.5 Environment Cleanup Event", "#### 5.9.5 🧹 Environment Cleanup Event"
$content = $content -replace "#### 5\.10\.1 Dev Box Accelerator", "#### 5.10.1 📦 Dev Box Accelerator"
$content = $content -replace "#### 5\.10\.2 DevCenter Project", "#### 5.10.2 🗂️ DevCenter Project"
$content = $content -replace "#### 5\.10\.3 Dev Box Pool", "#### 5.10.3 💻 Dev Box Pool"
$content = $content -replace "#### 5\.10\.4 Environment Type", "#### 5.10.4 🌍 Environment Type"
$content = $content -replace "#### 5\.10\.5 GitHub PAT", "#### 5.10.5 🔑 GitHub PAT"
$content = $content -replace "#### 5\.10\.6 Azure Landing Zone", "#### 5.10.6 🏗️ Azure Landing Zone"
$content = $content -replace "#### 5\.10\.7 Configuration Contract", "#### 5.10.7 📋 Configuration Contract"
$content = $content -replace "#### 5\.10\.8 Work Item Hierarchy", "#### 5.10.8 📊 Work Item Hierarchy"
$content = $content -replace "#### 5\.11\.1 Feature Availability Rate", "#### 5.11.1 📈 Feature Availability Rate"
$content = $content -replace "#### 5\.11\.2 Deployment Success Rate", "#### 5.11.2 📊 Deployment Success Rate"
$content = $content -replace "#### 5\.11\.3 Developer Onboarding Time", "#### 5.11.3 ⏱️ Developer Onboarding Time"
$content = $content -replace "#### 5\.11\.4 Definition-of-Done Completion Rate", "#### 5.11.4 ✅ Definition-of-Done Completion Rate"

# ── Main section heading emojis (## level) ───────────────────────────────────
$content = $content -replace "## 1\. Executive Summary", "## 1. 📋 Executive Summary"
$content = $content -replace "## 2\. Architecture Landscape", "## 2. 🗺️ Architecture Landscape"
$content = $content -replace "## 3\. Architecture Principles", "## 3. 🏛️ Architecture Principles"
$content = $content -replace "## 4\. Current State Baseline", "## 4. 📊 Current State Baseline"
$content = $content -replace "## 5\. Component Catalog", "## 5. 📦 Component Catalog"
$content = $content -replace "## 8\. Dependencies & Integration", "## 8. 🔗 Dependencies & Integration"

# ── ### Overview / ### Summary / ### Business Capability Map ─────────────────
$content = $content -replace "### Overview", "### 🔍 Overview"
$content = $content -replace "### Summary", "### ✅ Summary"
$content = $content -replace "### Business Capability Map", "### 🗺️ Business Capability Map"

# ── Section 8 subsection heading emojis ──────────────────────────────────────
$content = $content -replace "### Capability-to-Application Mapping", "### 🗺️ Capability-to-Application Mapping"
$content = $content -replace "### Value Stream-to-Technology Mapping", "### 🌊 Value Stream-to-Technology Mapping"
$content = $content -replace "### Business Rules-to-Technology Enforcement Mapping", "### 📋 Business Rules-to-Technology Enforcement Mapping"

# ── Section 3 principle attribute table header emojis ────────────────────────
# These are key-value tables: | Attribute | Value |
$content = $content -replace "(?m)^\| Attribute +\| Value +\|", "| 🏛️ Attribute | 📝 Value |"
$content = $content -replace "(?m)^\| ----------[- |]+\|", "| --- | --- |"

# ── Section 5 attribute table header (| Attribute | Value |) ─────────────────
# Already handled by Section 3 pattern above (same structure)

# ── Section 2 Overview text: update table format description ─────────────────
$content = $content -replace "standardized five-column format capturing the component name, description, source file reference, confidence score, and capability maturity level", "standardized two-column format capturing the component name and description"
$content = $content -replace "Confidence scores were calculated using the weighted formula: 30% filename signal \+ 25% path signal \+ 35% content keyword signal \+ 10% cross-reference signal\. All included components score ≥ 0\.75, meeting the 0\.70 threshold required for classification\. The dominant", "The dominant"

# ─────────────────────────────────────────────────────────────────────────────
# PASS 3: Add Quick TOC after the first `---` separator (after metadata header)
# ─────────────────────────────────────────────────────────────────────────────
$toc = @"

## 📑 Quick Table of Contents

| # | Section | Key Content |
|---|---------|-------------|
| [1](#1-executive-summary) | 📋 Executive Summary | Platform overview · 47 components · maturity profile |
| [2](#2-architecture-landscape) | 🗺️ Architecture Landscape | Component inventory · 11 TOGAF types · capability map |
| [3](#3-architecture-principles) | 🏛️ Architecture Principles | 6 governance principles · principle hierarchy diagram |
| [4](#4-current-state-baseline) | 📊 Current State Baseline | As-is maturity assessment · capability heatmap |
| [5](#5-component-catalog) | 📦 Component Catalog | 47-component specifications · process flow diagrams |
| [8](#8-dependencies--integration) | 🔗 Dependencies & Integration | Cross-layer mappings · integration dependency graph |

---

"@

# Insert TOC right after **Components Found**: 47 + newline + ---
$content = $content -replace "(\*\*Components Found\*\*: 47\n\n---\n)", "`$1$toc"

# ─────────────────────────────────────────────────────────────────────────────
# PASS 4: Add Principle Hierarchy diagram at end of Section 3
#         (before the closing --- separator that precedes ## 4.)
# ─────────────────────────────────────────────────────────────────────────────
$principleHierarchyDiagram = @"

### 🗺️ Architecture Principles Hierarchy

```mermaid
---
title: DevExp-DevBox Architecture Principles Hierarchy
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: DevExp-DevBox Architecture Principles Hierarchy
    accDescr: Shows six architecture principles organized into four governance tiers — Foundation, Security and Knowledge, Operational Transparency, and Strategic Alignment — with dependency arrows showing how lower-tier principles enable higher-tier ones.

    %% ═══════════════════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v1.1
    %% (Semantic + Structural + Font + Accessibility Governance)
    %% ═══════════════════════════════════════════════════════════════════════════
    %% PHASE 1 - FLUENT UI: All styling uses approved Fluent UI palette only
    %% PHASE 2 - GROUPS: Every subgraph has semantic color via style directive
    %% PHASE 3 - COMPONENTS: Every node has semantic classDef + icon prefix
    %% PHASE 4 - ACCESSIBILITY: accTitle/accDescr present, WCAG AA contrast
    %% PHASE 5 - STANDARD: Governance block present, classDefs centralized
    %% ═══════════════════════════════════════════════════════════════════════════

    subgraph foundation["🏗️ Foundation — Deployment Reliability"]
        p2("📋 P2: Configuration-as-Code First"):::core
        p6("🔁 P6: Idempotent Operations"):::core
    end

    subgraph governance["🔒 Governance — Security & Knowledge"]
        p3("🛡️ P3: Least-Privilege Access"):::warning
        p5("📝 P5: Documentation-as-Code"):::warning
    end

    subgraph operational["📡 Operational — Transparency"]
        p4("📡 P4: Observability-by-Default"):::success
    end

    subgraph strategic["🎯 Strategic — Alignment"]
        p1("⚙️ P1: Capability-Driven Design"):::data
    end

    p2 -->|"governs"| p3
    p2 -->|"enables"| p6
    p6 -->|"underpins"| p4
    p3 -->|"enforces constraints on"| p1
    p5 -->|"documents intent for"| p1
    p4 -->|"informs decisions in"| p1

    style foundation fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    style governance fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    style operational fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    style strategic fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
```

"@

# Insert diagram before the "---" that separates Section 3 and Section 4.
# The separator after Section 3 is "---" preceded by the 3.6 Idempotent Operations table content.
# Identify by matching the last principle table closing + separator.
$content = $content -replace "(\| \*\*Implications\*\*[^\n]+\n\n---\n\n## 4\.)", "`$1"

# More reliable: insert before "\n\n---\n\n## 4. 📊"
$content = $content -replace "(\n\n---\n\n## 4\. 📊 Current State Baseline)", "$principleHierarchyDiagram`n`n---`n`n## 4. 📊 Current State Baseline"

# ─────────────────────────────────────────────────────────────────────────────
# Write result
# ─────────────────────────────────────────────────────────────────────────────
Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
Write-Host "✅ Transform complete. File saved: $path"

# Quick validation
$result = Get-Content $path -Raw
$mermaidCount = ([regex]::Matches($result, '```mermaid')).Count
$sectionCount = ([regex]::Matches($result, '^## \d+\.', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
Write-Host "   Mermaid diagrams: $mermaidCount (need ≥ 6)"
Write-Host "   Section headings: $sectionCount (need = 6)"
$tocPresent = $result -match "📑 Quick Table of Contents"
Write-Host "   Quick TOC present: $tocPresent"
$sourceInTables = [regex]::Matches($result, '(?m)^\| \*\*Source\*\*').Count
$confidenceInTables = [regex]::Matches($result, '(?m)^\| \*\*Confidence\*\*').Count
$maturityInTables = [regex]::Matches($result, '(?m)^\| \*\*Maturity\*\*').Count
$evidenceInTables = [regex]::Matches($result, '(?m)^\| \*\*Evidence\*\*').Count
Write-Host "   Remaining **Source** table rows: $sourceInTables (need = 0)"
Write-Host "   Remaining **Confidence** table rows: $confidenceInTables (need = 0)"
Write-Host "   Remaining **Maturity** table rows: $maturityInTables (need = 0)"
Write-Host "   Remaining **Evidence** table rows: $evidenceInTables (need = 0)"

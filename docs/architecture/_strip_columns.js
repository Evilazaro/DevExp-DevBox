// Strip source, evidence, confidence, and maturity content from data-architecture.md
const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'data-architecture.md');
let content = fs.readFileSync(filePath, 'utf8');
let lines = content.split('\n');

// --- Column removal from markdown tables ---
const REMOVE_COLUMNS = ['source file', 'source', 'confidence', 'evidence source', 'evidence'];

function shouldRemoveCol(headerText) {
  const cleaned = headerText.replace(/[^\w\s]/g, '').trim().toLowerCase();
  return REMOVE_COLUMNS.includes(cleaned);
}

function isTableRow(line) {
  const t = line.trim();
  return t.startsWith('|') && t.endsWith('|');
}

function isSeparatorRow(line) {
  if (!isTableRow(line)) return false;
  const t = line.trim();
  return /^\|[\s\-:|]+\|$/.test(t);
}

function splitTableCols(line) {
  let s = line.trim();
  if (s.startsWith('|')) s = s.slice(1);
  if (s.endsWith('|')) s = s.slice(0, -1);
  return s.split('|');
}

const result = [];
let i = 0;
while (i < lines.length) {
  const line = lines[i];

  if (isTableRow(line) && i + 1 < lines.length && isSeparatorRow(lines[i + 1])) {
    const headerCells = splitTableCols(line);
    const sepCells = splitTableCols(lines[i + 1]);

    const keepIndices = [];
    for (let idx = 0; idx < headerCells.length; idx++) {
      if (!shouldRemoveCol(headerCells[idx])) {
        keepIndices.push(idx);
      }
    }

    if (keepIndices.length === headerCells.length) {
      result.push(line);
      i++;
      continue;
    }

    if (keepIndices.length === 0) {
      i += 2;
      while (i < lines.length && isTableRow(lines[i])) i++;
      continue;
    }

    // Rebuild header
    const newHeader = keepIndices.map(j => headerCells[j].trim());
    const newSep = keepIndices.filter(j => j < sepCells.length).map(j => sepCells[j].trim());
    result.push('| ' + newHeader.join(' | ') + ' |');
    result.push('| ' + newSep.join(' | ') + ' |');
    i += 2;

    // Process data rows
    while (i < lines.length && isTableRow(lines[i])) {
      const dataCells = splitTableCols(lines[i]);
      const newData = keepIndices.filter(j => j < dataCells.length).map(j => dataCells[j].trim());
      result.push('| ' + newData.join(' | ') + ' |');
      i++;
    }
    continue;
  }

  result.push(line);
  i++;
}

content = result.join('\n');

// --- Remove specific rows from Key Findings table ---
content = content.replace(/\n\| Average Confidence[^\n]*\|/g, '');
content = content.replace(/\n\| Components Below Threshold[^\n]*\|/g, '');

// --- Remove specific rows from Data Quality Scorecard ---
content = content.replace(/\n\| Source Traceability[^\n]*\|/g, '');
content = content.replace(/\n\| Classification Coverage[^\n]*\|/g, '');

// --- Remove confidence sentence from Executive Summary Overview (multi-line) ---
content = content.replace(
  / Average confidence across all identified\ncomponents is 0\.89, reflecting high traceability to source files\./g,
  ''
);
content = content.replace(
  / Average confidence across all identified components is 0\.89, reflecting high traceability to source files\./g,
  ''
);

// --- Remove Coverage Summary paragraph (mentions maturity) ---
content = content.replace(
  /### Coverage Summary\n\n[\s\S]*?(?=\n---)/,
  ''
);

// --- Remove Governance Maturity heading and table ---
content = content.replace(
  /### Governance Maturity\n\n\|[^\n]*\|\n\|[^\n]*\|\n(\|[^\n]*\|\n)*/g,
  ''
);

// --- Remove confidence scoring formula mention from Section 5 Overview ---
content = content.replace(
  /\nComponents were identified using a confidence scoring formula \(30% filename \+\n25% path \+ 35% content \+ 10% cross-reference\) with a minimum threshold of 0\.7\./g,
  ''
);
content = content.replace(
  / Components were identified using a confidence scoring formula[^.]*\./g,
  ''
);

// --- Remove "Components below threshold" sentence ---
content = content.replace(
  /\n\nComponents below the confidence threshold were excluded\. All included components\nhave verified source file references and correct layer classification — no\nApplication, Business, or Technology layer components are misclassified as Data\./g,
  '\n\nAll included components have correct layer classification — no\nApplication, Business, or Technology layer components are misclassified as Data.'
);
content = content.replace(
  /Components below the confidence threshold were excluded\. /g,
  ''
);

// --- Remove confidence score mention from Section 6 Overview ---
content = content.replace(
  / with confidence scores based on the\nconsistency and explicitness of the patterns observed/g,
  ''
);
content = content.replace(
  / with confidence scores based on the consistency and explicitness of the patterns observed/g,
  ''
);

// --- Remove "Data Maturity Level 2 (Managed)" from Section 4 Summary ---
content = content.replace(
  /The current state baseline reveals a well-governed infrastructure platform at\nData Maturity Level 2 \(Managed\)\./g,
  'The current state baseline reveals a well-governed infrastructure platform.'
);

// --- Remove Section 3 traceable sentence ---
content = content.replace(
  / Each principle\nbelow is traceable to specific implementation patterns in the codebase\./g,
  ''
);
content = content.replace(
  / Each principle below is traceable to specific implementation patterns in the codebase\./g,
  ''
);

// --- Remove gov maturity from Section 4 Overview ---
content = content.replace(
  /, and governance maturity based on RBAC implementation and\ntagging compliance/g,
  ''
);

// --- Clean up double blank lines ---
while (content.includes('\n\n\n')) {
  content = content.replace(/\n\n\n/g, '\n\n');
}

fs.writeFileSync(filePath, content, 'utf8');
console.log('Done. Stripped source/evidence/confidence/maturity content.');

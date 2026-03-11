const fs = require('fs');
const lines = fs.readFileSync('z:\\platengineering\\README.md', 'utf8').split('\n');
let inCode = false;
const pathPat = /(?<!`)(?:infra\/|src\/|docs\/|setUp\.|cleanSetUp\.|main\.bicep|main\.parameters|azureResources\.yaml|security\.yaml|devcenter\.yaml|\.schema\.json|azure\.yaml|azure-pwh\.yaml)/;
const issues = [];
for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  if (line.startsWith('```')) { inCode = !inCode; continue; }
  if (inCode) continue;
  if (line.startsWith('|')) continue;
  if (line.startsWith('![')) continue;
  if (line.startsWith('- [')) continue;
  const m = line.match(pathPat);
  if (m) issues.push('Line ' + (i+1) + ': ' + line.trim().substring(0, 120));
}
console.log('File paths outside backticks (non-code-block): ' + issues.length);
issues.forEach(i => console.log(i));
if (!issues.length) console.log('F3 PASSES!');

"""Strip source, evidence, confidence, and maturity content from data-architecture.md"""
import re
import sys

INPUT = "data-architecture.md"
OUTPUT = "data-architecture.md"

with open(INPUT, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.split("\n")

# --- Column removal from markdown tables ---
# Columns to remove (case-insensitive, partial match after stripping emoji)
REMOVE_COLUMNS = [
    "source file", "source", "confidence", "evidence source", "evidence"
]

def should_remove_col(header_text):
    """Check if a column header matches a removal target."""
    # Strip emoji and whitespace
    cleaned = re.sub(r'[^\w\s]', '', header_text).strip().lower()
    for target in REMOVE_COLUMNS:
        if cleaned == target:
            return True
    return False

def is_table_row(line):
    return line.strip().startswith("|") and line.strip().endswith("|")

def is_separator_row(line):
    return is_table_row(line) and all(
        c in "-| :" for c in line.strip()
    )

def split_table_cols(line):
    """Split a table row into cells, preserving leading/trailing pipes."""
    stripped = line.strip()
    if stripped.startswith("|"):
        stripped = stripped[1:]
    if stripped.endswith("|"):
        stripped = stripped[:-1]
    return [c for c in stripped.split("|")]

def rebuild_table_row(cells):
    return "| " + " | ".join(c.strip().center(len(c.strip())) for c in cells) + " |"

def rebuild_separator_row(cells):
    parts = []
    for c in cells:
        c = c.strip()
        parts.append(c)
    return "| " + " | ".join(parts) + " |"

# Process the file line by line
result = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # Detect start of a table (header row)
    if is_table_row(line) and i + 1 < len(lines) and is_separator_row(lines[i + 1]):
        # Parse the header row
        header_cells = split_table_cols(line)
        sep_cells = split_table_cols(lines[i + 1])
        
        # Determine which columns to keep
        keep_indices = []
        for idx, cell in enumerate(header_cells):
            if not should_remove_col(cell):
                keep_indices.append(idx)
        
        if len(keep_indices) == len(header_cells):
            # No columns to remove, keep as-is
            result.append(line)
            i += 1
            continue
        
        if len(keep_indices) == 0:
            # All columns removed - skip entire table
            i += 2  # skip header + separator
            while i < len(lines) and is_table_row(lines[i]):
                i += 1
            continue
        
        # Rebuild header
        new_header = [header_cells[j] for j in keep_indices]
        new_sep = [sep_cells[j] for j in keep_indices if j < len(sep_cells)]
        
        result.append("| " + " | ".join(h.strip() for h in new_header) + " |")
        result.append("| " + " | ".join(s.strip() for s in new_sep) + " |")
        
        i += 2  # advance past header + separator
        
        # Process data rows
        while i < len(lines) and is_table_row(lines[i]):
            data_cells = split_table_cols(lines[i])
            new_data = [data_cells[j] for j in keep_indices if j < len(data_cells)]
            result.append("| " + " | ".join(d.strip() for d in new_data) + " |")
            i += 1
        continue
    
    result.append(line)
    i += 1

content = "\n".join(result)

# --- Remove specific rows from Key Findings table ---
# Remove "Average Confidence" and "Components Below Threshold" rows
content = re.sub(r'\n\| Average Confidence[^\n]*\|', '', content)
content = re.sub(r'\n\| Components Below Threshold[^\n]*\|', '', content)

# --- Remove specific rows from Data Quality Scorecard ---
content = re.sub(r'\n\| Source Traceability[^\n]*\|', '', content)
content = re.sub(r'\n\| Classification Coverage[^\n]*\|', '', content)

# --- Remove confidence sentence from Executive Summary Overview ---
content = content.replace(
    " Average confidence across all identified\ncomponents is 0.89, reflecting high traceability to source files.",
    ""
)
# Also try single-line variant
content = content.replace(
    " Average confidence across all identified components is 0.89, reflecting high traceability to source files.",
    ""
)

# --- Remove Coverage Summary paragraph (mentions maturity) ---
content = re.sub(
    r'### Coverage Summary\n\n.*?(?=\n---)',
    '',
    content,
    flags=re.DOTALL
)

# --- Remove Governance Maturity heading and table ---
content = re.sub(
    r'### Governance Maturity\n\n\|[^\n]*\|\n\|[^\n]*\|\n(\|[^\n]*\|\n)*',
    '',
    content
)

# --- Remove confidence scoring formula mention from Section 5 Overview ---
content = content.replace(
    "\nComponents were identified using a confidence scoring formula (30% filename +\n25% path + 35% content + 10% cross-reference) with a minimum threshold of 0.7.",
    ""
)
content = content.replace(
    "\n\nComponents below the confidence threshold were excluded. All included components\nhave verified source file references and correct layer classification — no\nApplication, Business, or Technology layer components are misclassified as Data.",
    " All included components\nhave correct layer classification — no\nApplication, Business, or Technology layer components are misclassified as Data."
)

# --- Remove confidence score mention from Section 6 Overview ---
content = content.replace(
    " with confidence scores based on the\nconsistency and explicitness of the patterns observed",
    ""
)
content = content.replace(
    " with confidence scores based on the consistency and explicitness of the patterns observed",
    ""
)

# --- Remove "Data Maturity Level 2 (Managed)" from Section 4 Summary ---
content = content.replace(
    "The current state baseline reveals a well-governed infrastructure platform at\nData Maturity Level 2 (Managed).",
    "The current state baseline reveals a well-governed infrastructure platform."
)

# --- Remove Section 3 traceable sentence ---
content = content.replace(
    " Each principle\nbelow is traceable to specific implementation patterns in the codebase.",
    ""
)
content = content.replace(
    " Each principle below is traceable to specific implementation patterns in the codebase.",
    ""
)

# --- Remove "governance maturity" phrase from Section 4 Overview ---
content = content.replace(
    ", and governance maturity based on RBAC implementation and\ntagging compliance",
    ""
)

# --- Clean up double blank lines ---
while "\n\n\n" in content:
    content = content.replace("\n\n\n", "\n\n")

with open(OUTPUT, "w", encoding="utf-8") as f:
    f.write(content)

print("Done. Stripped source/evidence/confidence/maturity content.")

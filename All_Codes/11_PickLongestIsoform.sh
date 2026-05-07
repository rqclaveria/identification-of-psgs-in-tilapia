#!/bin/bash

# Loop through every file starting with clean_ and ending in .fasta
for f in clean_*.fasta; do
    # Check if the file actually exists to avoid errors
    [ -e "$f" ] || continue

    python3 -c "
import sys
from collections import defaultdict

# 1. Setup storage: A dictionary to hold the 'winning' longest sequence for each gene
genes = defaultdict(lambda: {'len': -1, 'seq': '', 'header': ''})

# We pass the filename from Bash ($f) into Python via sys.stdin or a direct open
with open('$f', 'r') as file:
    current_header = ''
    current_seq = []
    
    for line in file:
        line = line.strip()
        if line.startswith('>'):
            if current_header:
                # 2. Logic: Split header by '::' and take the first part as the Gene Name
                gene_id = current_header.split('::')[0].replace('>', '')
                seq_str = ''.join(current_seq)
                
                # 3. Comparison: If this version is longer than the one we have, save it
                if len(seq_str) > genes[gene_id]['len']:
                    genes[gene_id] = {'len': len(seq_str), 'seq': seq_str, 'header': current_header}
            
            current_header = line
            current_seq = []
        else:
            current_seq.append(line)
            
    # Capture the very last sequence in the file
    if current_header:
        gene_id = current_header.split('::')[0].replace('>', '')
        seq_str = ''.join(current_seq)
        if len(seq_str) > genes[gene_id]['len']:
            genes[gene_id] = {'len': len(seq_str), 'seq': seq_str, 'header': current_header}

# 4. Output: Write only the longest isoforms to a new 'final' file
output_name = 'final_' + '$f'
with open(output_name, 'w') as out:
    for g in genes.values():
        out.write(f\"{g['header']}\n{g['seq']}\n\")
"
    echo "Successfully picked longest isoforms for: $f"
done
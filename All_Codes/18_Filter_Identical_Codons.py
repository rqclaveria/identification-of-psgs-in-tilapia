import os
import shutil
from Bio import SeqIO

input_dir = "Filtered_Alignments"
output_dir = "Final_Codon_Alignments"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

variable_count = 0
fixed_count = 0

for filename in os.listdir(input_dir):
    if filename.endswith((".fasta", ".fa", ".aln")):
        filepath = os.path.join(input_dir, filename)
        sequences = [str(record.seq).upper() for record in SeqIO.parse(filepath, "fasta")]
        
        # Check if all sequences in the alignment are identical
        if len(set(sequences)) > 1:
            shutil.copy(filepath, os.path.join(output_dir, filename))
            variable_count += 1
        else:
            fixed_count += 1

print(f"Variable genes kept: {variable_count}")
print(f"Identical genes removed: {fixed_count}")
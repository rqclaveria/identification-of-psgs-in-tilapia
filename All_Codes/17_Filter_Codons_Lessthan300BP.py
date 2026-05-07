import os
import shutil
from Bio import SeqIO

# Configuration
input_dir = "Codon_Alignments"
output_dir = "Filtered_Alignments"
min_length = 300

# Create output directory if it doesn't exist
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

print(f"Starting filtration... Target length: >={min_length} bp")

passed_count = 0
failed_count = 0

# Loop through files in the input folder
for filename in os.listdir(input_dir):
    if filename.endswith(".fasta") or filename.endswith(".fa") or filename.endswith(".aln"):
        filepath = os.path.join(input_dir, filename)
        
        try:
            # Read the first sequence to check the alignment length
            record = next(SeqIO.parse(filepath, "fasta"))
            seq_length = len(record.seq)
            
            if seq_length >= min_length:
                shutil.copy(filepath, os.path.join(output_dir, filename))
                passed_count += 1
            else:
                failed_count += 1
        except Exception as e:
            print(f"Error processing {filename}: {e}")

print("-" * 30)
print(f"Filtration Complete!")
print(f"Genes passed: {passed_count}")
print(f"Genes removed: {failed_count}")
print(f"Filtered files are located in: {output_dir}")
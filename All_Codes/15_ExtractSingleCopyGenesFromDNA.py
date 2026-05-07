import pandas as pd
import os
from Bio import SeqIO
import re

# 1. Setup
tsv_file = "orthogroups.tsv"
input_dir = "DNA_Renamed_Simple"
output_dir = "DNA_FASTAs_PAL2NAL_Ready"

os.makedirs(output_dir, exist_ok=True)

# Function to extract coordinates (e.g., 43266-50465) from complex headers
def get_coord_num(text):
    # Searches for a pattern of numbers-numbers (usually coordinates)
    match = re.search(r'([0-9]+-[0-9]+)', str(text))
    return match.group(1) if match else str(text)

# 2. Filter for Single-Copy Orthogroups
print(f"Reading Master Map: {tsv_file}")
df = pd.read_csv(tsv_file, sep='\t', index_col=0)

# Drop any rows with missing data (N/A)
single_copy_df = df.dropna().copy()

# Ensure exactly one gene per species (no commas in cells)
mask = single_copy_df.map(lambda x: len(str(x).split(',')) == 1).all(axis=1)
final_list = single_copy_df[mask]
print(f"Found {len(final_list)} potential single-copy orthogroups.")

# 3. Indexing the DNA Sequences
seq_db = {}
dna_files = [f for f in os.listdir(input_dir) if f.endswith(("_cds.fasta", "_cds.fa"))]

for fa in dna_files:
    # Extract species prefix (e.g., SRR11842903) from filename
    species_prefix = fa.split('_')[0] 
    print(f"Indexing {fa}...")
    
    input_path = os.path.join(input_dir, fa)
    for record in SeqIO.parse(input_path, "fasta"):
        coord = get_coord_num(record.id)
        
        # Create a unique key to match the TSV entries
        # Format: SRR11842903_43266-50465
        unique_key = f"{species_prefix}_{coord}"
        
        # Simplify the header for PAL2NAL (Just the Species ID)
        record.id = species_prefix
        record.description = ""
        
        seq_db[unique_key] = record

# 4. Extraction and Grouping
success_count = 0
print("Starting extraction into Orthogroups...")

for og_id, row in final_list.iterrows():
    found_sequences = []
    
    for gene_id in row:
        target_str = str(gene_id).strip()
        # The gene_id in the TSV usually looks like SRR11842924_AqAm_ctsd__...
        target_species = target_str.split('_')[0]
        target_coord = get_coord_num(target_str)
        
        lookup_key = f"{target_species}_{target_coord}"
        match = seq_db.get(lookup_key)
        
        if match:
            found_sequences.append(match)

    # Validate: Must have exactly 9 sequences and 9 unique species
    if len(found_sequences) == 9:
        unique_species_check = set(s.id for s in found_sequences)
        if len(unique_species_check) == 9:
            output_filename = os.path.join(output_dir, f"{og_id}.dna.fa")
            with open(output_filename, "w") as out:
                SeqIO.write(found_sequences, out, "fasta")
            success_count += 1

print(f"--- Process Complete ---")
print(f"Successfully created {success_count} OG-specific DNA files in '{output_dir}'.")
import os
from Bio import SeqIO

input_dir = "Aligned_FASTAs"
output_dir = "PAL2NAL_Ready_FASTAs"
os.makedirs(output_dir, exist_ok=True)

for filename in os.listdir(input_dir):
    if filename.endswith(".fa") or filename.endswith(".fasta"):
        input_path = os.path.join(input_dir, filename)
        output_path = os.path.join(output_dir, filename)
        
        sequences = []
        for record in SeqIO.parse(input_path, "fasta"):
            new_id = record.id.split('_')[0]
            record.id = new_id
            record.description = ""
            sequences.append(record)
        
        with open(output_path, "w") as out:
            SeqIO.write(sequences, out, "fasta")


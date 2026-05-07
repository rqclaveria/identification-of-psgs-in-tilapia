

for f in cds_fasta/*.fasta; do
    base=$(basename "$f")
    seqkit translate "$f" --trim --clean > "Protein_Sequences/pep_${base}"
    
    echo "translated: $f"
done
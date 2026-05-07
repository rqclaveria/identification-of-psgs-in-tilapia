mkdir -p orthofinder_input

for f in final_clean_*.fasta; do
    # Only get sample ID from file name
    sample_id=$(echo "$f" | sed 's/final_clean_pep_//; s/_cds.fasta//')

    # Appends sample ID to header
    sed "s/^>/>${sample_id}_/" "$f" > "orthofinder_input/${sample_id}_formatted.fa"
    
    echo "Added ID to: $sample_id"
done
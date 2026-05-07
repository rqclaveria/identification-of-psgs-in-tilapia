for f in *.fasta; do
seqkit rmdup -n "$f" -o "clean_$f"
done
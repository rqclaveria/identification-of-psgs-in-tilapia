mkdir -p Codon_Alignments
> failed_ogs.txt

for prot in PAL2NAL_Ready_FASTAs/*.fa; do
    og=$(basename "$prot" .fa)
    
    pal2nal.pl "$prot" "DNA_FASTAs_PAL2NAL_Ready/${og}.dna.fa" -output fasta > "Codon_Alignments/${og}.codon.fa" 2>temp_err.txt
    
    if [ $? -ne 0 ]; then
        echo "$og" >> failed_ogs.txt
        rm "Codon_Alignments/${og}.codon.fa"
    fi
done

rm temp_err.txt
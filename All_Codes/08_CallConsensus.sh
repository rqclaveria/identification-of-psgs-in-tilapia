#!/bin/bash

REF="reference/GCF_001858045.2_O_niloticus_UMD_NMBU_genomic.fna"
MERGED_VCF="merged_vcf/tilapia_merged_filtered_final.vcf.gz"
BED12="GFF/spliced_genes.bed12"

mkdir -p cds_fasta

SAMPLES=$(bcftools query -l "$MERGED_VCF" | tr -d '\r')

for SM in $SAMPLES; do

    bcftools consensus -f "$REF" -s "$SM" -H 1 "$MERGED_VCF" > "temp_${SM}.fasta"

    bedtools getfasta \
        -fi "temp_${SM}.fasta" \
        -bed "$BED12" \
        -s -name -split \
        -fo "cds_fasta/${SM}_cds.fasta"

    rm "temp_${SM}.fasta" "temp_${SM}.fasta.fai"

    echo "${SM}_cds.fasta created"
done

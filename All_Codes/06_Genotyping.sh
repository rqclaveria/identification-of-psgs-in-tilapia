#!/bin/bash
set -euo pipefail

REF="reference/GCF_001858045.2_O_niloticus_UMD_NMBU_genomic.fna"
DB_DIR="gatk_analysis/tilapia_analysis/05_genomicsdb"
VCF_DIR="gatk_analysis/tilapia_analysis/06_vcfs/scattered_vcfs"

mkdir -p "$VCF_DIR"

for INPUT_DB in "$DB_DIR"/*; do

    INTERVAL_NAME=$(basename "$INPUT_DB")

    gatk --java-options "-Xmx30g" GenotypeGVCFs \
        -R "$REF_GENOME" \
        -V "gendb://"${DB_DIR}/${INPUT_DB}" \
        -O "${VCF_DIR}/${INTERVAL_NAME}.vcf.gz"

done
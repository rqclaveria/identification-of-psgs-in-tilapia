#!/bin/bash
set -euo pipefail

REF="reference/GCF_001858045.2_O_niloticus_UMD_NMBU_genomic.fna"
INPUT_DIR="gatk_analysis/01_preprocessing"
GVCF_DIR="gatk_analysis/tilapia_analysis/04_gvcfs"
mkdir -p "$GVCF_DIR"

for INPUT_BAM in "${INPUT_DIR}"/*.dedup.bam; do
    SAMPLE=$(basename "$INPUT_BAM" .dedup.bam)
    OUT_GVCF="${GVCF_DIR}/${SAMPLE}.g.vcf.gz"

    if [[ -f "$OUT_GVCF" ]]; then
        continue
    fi

    gatk --java-options "-Xmx8G" HaplotypeCaller \
        -R "$REF" \
        -I "$INPUT_BAM" \
        -O "$OUT_GVCF" \
        -ERC GVCF

done

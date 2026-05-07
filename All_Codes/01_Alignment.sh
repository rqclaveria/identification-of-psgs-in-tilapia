set -euo pipefail

REF="reference/GCF_001858045.2_O_niloticus_UMD_NMBU_genomic.fna"
mkdir -p "aligned"

for SAMPLE in WGS/*; do
    SAMPLE_ID=$(basename "${SAMPLE}")
    R1="${SAMPLE}/${SAMPLE_ID}_1.fastq.gz"
    R2="${SAMPLE}/${SAMPLE_ID}_2.fastq.gz"
    OUT_DIR="aligned/${SAMPLE_ID}"
    BAM="${OUT_DIR}/${SAMPLE_ID}.sorted.bam"

    if [[ -f "${BAM}" && -f "${BAM}.bai" ]]; then
        echo "Skipping ${SAMPLE_ID} (already aligned)"
        continue
    fi

    mkdir -p "${OUT_DIR}"

    bwa mem -t 8 -M "${REF}" "${R1}" "${R2}" | \
    samtools view -@ 8 -b -h - | \
    samtools sort -@ 8 -o "${BAM}" -

    samtools index "${BAM}"

done
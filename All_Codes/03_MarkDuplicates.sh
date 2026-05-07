set -euo pipefail

INPUT_DIR="aligned/with_RG"

OUTPUT_BAM_DIR="gatk_analysis/01_preprocessing"
METRICS_DIR="${OUTPUT_BAM_DIR}/metrics"
mkdir -p "$OUTPUT_BAM_DIR" "$METRICS_DIR"

for INPUT_BAM in "${INPUT_DIR}"/*.RG.bam; do
    SAMPLE=$(basename "$INPUT_BAM" .RG.bam)
    OUTPUT_BAM="${OUTPUT_BAM_DIR}/${SAMPLE}.dedup.bam"
    METRICS_FILE="${METRICS_DIR}/${SAMPLE}.dedup_metrics.txt"

    if [[ -f "$OUTPUT_BAM" && -f "${OUTPUT_BAM}.bai" ]]; then
        echo "Skipping ${SAMPLE} (already deduped)"
        continue
    fi

gatk --java-options "-Xmx8G -Dsamjdk.compression_level=2" MarkDuplicates \
    -I "$INPUT_BAM" \
    -O "$OUTPUT_BAM" \
    -M "$METRICS_FILE" \
    --CREATE_INDEX true \
    --VALIDATION_STRINGENCY LENIENT

done
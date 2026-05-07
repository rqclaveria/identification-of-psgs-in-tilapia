set -euo pipefail

BASE_DIR="aligned"
OUT_DIR="$BASE_DIR/with_RG"
mkdir -p "$OUT_DIR"

for BAM in "$BASE_DIR"/*/*.sorted.bam; do
    SAMPLE=$(basename "$BAM" .sorted.bam)
    OUT_BAM="$OUT_DIR/${SAMPLE}.RG.bam"

    if [[ -f "$OUT_BAM" && -f "$OUT_BAM.bai" ]]; then
        continue
    fi

    gatk AddOrReplaceReadGroups \
        -I "$BAM" \
        -O "$OUT_BAM" \
        -RGID "$SAMPLE" \
        -RGLB "lib1" \
        -RGPL "ILLUMINA" \
        -RGPU "$SAMPLE.unit1" \
        -RGSM "$SAMPLE"

    samtools index "$OUT_BAM"
done

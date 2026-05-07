
set -euo pipefail

SCATTER_VCF_DIR="gatk_analysis/tilapia_analysis/06_vcfs/scattered_vcfs"
FINAL_VCF_DIR="gatk_analysis/tilapia_analysis/06_vcfs"
OUTPUT_VCF="${FINAL_VCF_DIR}/tilapia_merged.vcf.gz"
VCF_LIST="${FINAL_VCF_DIR}/vcf_merge_list.txt"
cd "$SCATTER_VCF_DIR"
LOG_FILE="${FINAL_VCF_DIR}/concat_log.txt"

OUT_DIR="gatk_analysis/tilapia_analysis/06_joint_vcfs"

mkdir "$OUT_DIR"
cd "$OUT_DIR"

exec > >(tee "$LOG_FILE") 2>&1

ls -1v *.vcf.gz > "$VCF_LIST"

n=$(wc -l < "$VCF_LIST")
echo "Found $n VCF parts"

if [[ "$n" -ne 40 ]]; then
    echo "ERROR: expected exactly 40 VCF files"
    exit 1
fi

bcftools concat -f "$VCF_LIST" -Oz -o "$OUTPUT_VCF"

bcftools index -t "$OUTPUT_VCF"

echo "Concatenation complete! Final VCF: $OUTPUT_VCF"
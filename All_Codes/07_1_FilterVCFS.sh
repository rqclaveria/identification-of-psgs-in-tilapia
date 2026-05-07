#Filtering

VCF_IN=tilapia_merged.vcf.gz
VCF_OUT=tilapia_merged_filtered.vcf.gz
VCF_GATK=tilapia_merged_filtered_gatk.vcf.gz
VCF_FINAL=tilapia_merged_filtered_final.vcf.gz
LOG_FILE="filtering.log"

echo "Filtering start: $(date)" > ${LOG_FILE}
echo "Input File: ${VCF_IN}" >> ${LOG_FILE}

gatk --java-options "-Xmx16g" VariantFiltration \
    -V ${VCF_IN} \
    -O ${VCF_OUT} \
    --filter-expression "QD < 2.0" --filter-name "QD_filter" \
    --filter-expression "FS > 60.0" --filter-name "FS_filter" \
    --filter-expression "SOR > 3.0" --filter-name "SOR_filter" \
    --filter-expression "MQ < 40.0" --filter-name "MQ_filter" \
    --filter-expression "MQRankSum < -12.5" --filter-name "MQRankSum_filter" \
    --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum_filter"
    --missing-values-evaluate-as-passing true



gatk IndexFeatureFile -I ${VCF_OUT}

gatk SelectVariants \
    -V ${VCF_OUT} \
    -select-type SNP \
    --restrict-alleles-to BIALLELIC \
    --exclude-filtered \
    -O ${VCF_GATK}

echo "Hard filtering with GATK complete, continuing with MAF and Missingness"

#MAF
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## 0.00000 0.07143 0.14286 0.19058 0.28571 0.50000

MAF=0.125
##remove singletons; since tilapia is diploid. Note that vcf tools work as >= 0.125, so you can't do 0.0625 because you would still include singletons

#MISSINGNESS
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0000  0.0000  0.1250  0.1819  0.2500  0.8750

MISS=0.875
##because the peak at 0.125 means there is 7/8 individuals with missing data;; aka something like this peak at 0.125 means that y fraction ## of SNPs are missing 12.5% of data; equivalent to 1 missing individual


vcftools --gzvcf $VCF_GATK \
  --maf $MAF \
  --max-missing $MISS \
  --recode --stdout | gzip -c > $VCF_FINAL

echo "done"
echo "Final Filter applied: MAF=${MAF}, Missingness=${MISS}" >> ${LOG_FILE}
echo "Output File: ${VCF_FINAL}" >> ${LOG_FILE}
echo "Filtering completed: $(date)" >> ${LOG_FILE}
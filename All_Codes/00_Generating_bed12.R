library(tidyverse)
library(dplyr)
library(stringr)
library(tidyr)
library(readr)

# 1. Read the file
bed <- read_tsv("cds.bed", col_names = FALSE, comment = "#")

# 2. Add an "Original Order" index based on the first time a geneID appears
# We use row_number() on the raw data so we know exactly where each gene started.
bed2 <- bed %>%
  mutate(
    orig_row = row_number(), 
    geneID = str_extract(X9, "ID=([^;]+)") %>% str_remove("ID="),
    geneID = if_else(is.na(geneID),
                     str_extract(X9, "Parent=([^;]+)") %>% str_remove("Parent="),
                     geneID),
    gene_name = str_extract(X9, "gene_name=([^;]+)") %>% str_remove("gene_name=")
  ) %>%  
  group_by(X1) %>%         
  fill(gene_name, .direction = "downup") %>%  
  ungroup()

# 3. Filter for CDS and keep that order index
bed_cdsonly <- bed2 %>%
  filter(X3 == "CDS") %>%
  mutate(start = X4 - 1) %>%
  select(X1, start, end = X5, strand = X7, geneID, gene_name, orig_row)

# 4. Collapse into BED12 while preserving order
bed12 <- bed_cdsonly %>%
  group_by(geneID) %>%
  # We still arrange by 'start' INTERNALLY so the blocks are listed left-to-right
  arrange(start) %>% 
  summarize(
    # Track the minimum original row number for this geneID group
    sorting_index = min(orig_row), 
    chrom = first(X1),
    chromStart = min(start),
    chromEnd = max(end),
    name = first(gene_name),
    score = 0,
    strand = first(strand),
    thickStart = chromStart,
    thickEnd = chromEnd,
    itemRgb = 0,
    blockCount = n(),
    blockSizes = paste0(end - start, collapse = ","),
    blockStarts = paste0(start - min(start), collapse = ",")
  ) %>%
  ungroup() %>%
  # 5. SORT BACK to the original file order
  arrange(sorting_index) %>%
  # 6. Final selection (dropping the sorting_index)
  select(chrom, chromStart, chromEnd, name, score, strand, 
         thickStart, thickEnd, itemRgb, blockCount, blockSizes, blockStarts)

View(bed12)
View(bed2)
# Save
write.table(bed12, "spliced_genes.bed12", sep="\t", quote=F, row.names=F, col.names=F)

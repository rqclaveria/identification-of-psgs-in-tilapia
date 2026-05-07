master_df <- read.csv("Master_Candidates_Screening_p05.csv")

strains <- c("GST", "GIFTW", "AqAm", "AqCor")


# Loop for merging lnL of null with old df from M0 vs M2
for (s in strains) {
  
  null_file <- paste0("New_lnL_Model_2_null_", s, ".csv")
  
  if (file.exists(null_file)) {
    null_data <- read.csv(null_file)
    
    strain_alt <- master_df[master_df$Hypothesis == s, ]
    
    merged <- merge(strain_alt, null_data[, c("Gene", "lnL")], by = "Gene")
    
    colnames(merged)[colnames(merged) == "lnL"] <- "lnL_null"
    
    merged$LRT_statistic <- 2 * (merged$lnL_m2 - merged$lnL_null)
    
    merged$LRT_statistic[merged$LRT_statistic < 0] <- 0
    
    merged$p_val_LRT <- pchisq(merged$LRT_statistic, df = 1, lower.tail = FALSE)
    
    merged$FDR_LRT <- p.adjust(merged$p_val_LRT, method = "BH")
    
    psg_data <- merged[merged$p_val_LRT < 0.05, ]
    
    psg_output_name <- paste0("PSGs_", s, ".csv")
    write.csv(psg_data, psg_output_name, row.names = FALSE)
    
    output_name <- paste0(s, "_Final_LRT_Results.csv")
    write.csv(merged, output_name, row.names = FALSE)
    writeLines(as.character(merged$Gene[merged$p_val_LRT < 0.05]), paste0(s, "_p05_List.txt"))
    
    assign(paste0(s, "_merged"), merged)
    
  } else {
    message("error no null ", s)
  }
}

sapply(list(GST=GST_merged, GIFTW=GIFTW_merged, AqAm=AqAm_merged, AqCor=AqCor_merged), 
       function(df) sum(df$FDR_LRT < 0.05, na.rm = TRUE))

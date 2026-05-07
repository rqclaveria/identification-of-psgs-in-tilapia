
m2 <- read.csv("model2_results_summary_final.csv")
m0 <- read.csv("model0_results_summary_final.csv")

full_data <- merge(m2, m0[, c("Gene", "omega", "dN", "dS", "lnL")], by = "Gene", suffixes = c("_m2", "_m0"))

# LRT Test
full_data$LRT_stat <- 2 * (full_data$lnL_m2 - full_data$lnL_m0)

# SET NEGATIVE LRT TO 0
full_data$LRT_stat[full_data$LRT_stat < 0] <- 0

full_data$omega_m2 <- as.numeric(full_data$omega_m2)
full_data$omega_m0 <- as.numeric(full_data$omega_m0)

#PVALUE
full_data$p_value <- pchisq(full_data$LRT_stat, df = 1, lower.tail = FALSE)

sum(full_data$p_value < 0.05 & full_data$omega_m2 > 1, na.rm = TRUE)

# APPLYING FDR CORRECTION
full_data$adj_p_value <- p.adjust(full_data$p_value, method = "BH")

fdr_hits <- sum(full_data$adj_p_value < 0.05 & full_data$omega_m2 > 1, na.rm = TRUE)

write.csv(full_data, "Model0vsModel2Final.csv", row.names = FALSE)
View(full_data)

# SEPARATE TO 4 STRAINS
GIFTW <- full_data[full_data$Hypothesis == "GIFTW", ]
GST <- full_data[full_data$Hypothesis == "GST", ]
AqAm <- full_data[full_data$Hypothesis == "AqAm", ]
AqCor <- full_data[full_data$Hypothesis == "AqCor", ]


filter_hits <- function(df) {
  hits <- df[df$p_value < 0.05 & df$omega_m2 > 1, ]
  return(as.character(hits$Gene))
}

giftw_list <- filter_hits(GIFTW)
gst_list   <- filter_hits(GST)
aqam_list  <- filter_hits(AqAm)
aqcor_list <- filter_hits(AqCor)

writeLines(giftw_list, "GIFTW_Candidates_M0M2.txt")
writeLines(gst_list,   "GST_Candidates_M0M2.txt")
writeLines(aqam_list,  "AqAm_Candidates_M0M2.txt")
writeLines(aqcor_list, "AqCor_Candidates_M0M2.txt")

cat("Candidate Genes:\n",
    "GIFTW:", length(giftw_list), "\n",
    "GST:  ", length(gst_list),   "\n",
    "AqAm: ", length(aqam_list),  "\n",
    "AqCor:", length(aqcor_list), "\n")


# combining > 1 and pval < 0.05
master_candidates <- rbind(
  GIFTW[GIFTW$p_value < 0.05 & GIFTW$omega_m2 > 1, ],
  GST[GST$p_value < 0.05 & GST$omega_m2 > 1, ],
  AqAm[AqAm$p_value < 0.05 & AqAm$omega_m2 > 1, ],
  AqCor[AqCor$p_value < 0.05 & AqCor$omega_m2 > 1, ]
)

master_candidates <- master_candidates[, c("Hypothesis", "Gene", "p_value", "omega_m2", "LRT_stat", "lnL_m2")]

write.csv(master_candidates, "Master_Candidates_Screening_p05.csv", row.names = FALSE)

# CHECK UNIQUE GENES
cat("Total:", nrow(master_candidates), "\n")
cat("Unique genes across all strains:", length(unique(master_candidates$Gene)), "\n")

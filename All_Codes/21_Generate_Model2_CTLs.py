import os

# --- CONFIGURATION ---
align_dir = "Final_Codon_Alignments"
hypotheses = {
    "GST": "gst_tree.newick",
    "AqAm": "aqam_tree.newick",
    "AqCor": "aqcor_tree.newick",
    "GIFTW": "giftw_tree.newick"
}

# --- SCRIPT START ---
# Updated to match your specific file extensions
genes = [f for f in os.listdir(align_dir) if f.endswith(".fasta") or f.endswith(".codon.fa")]

for hyp_name, tree_file in hypotheses.items():
    # Parent folder for the hypothesis (e.g., Branch_Runs_GST)
    hyp_parent = f"Branch_Runs_{hyp_name}"
    os.makedirs(hyp_parent, exist_ok=True)
    
    print(f"Generating gene folders and ctl files for {hyp_name}...")

    for gene in genes:
        gene_id = os.path.splitext(gene)[0]
        
        # Create a specific folder for EACH gene
        gene_folder = os.path.join(hyp_parent, gene_id)
        os.makedirs(gene_folder, exist_ok=True)
        
        # Path for the ctl file inside that gene folder
        ctl_path = os.path.join(gene_folder, "codeml.ctl")
        
        # Build the PAML Control File content
        # Note: Paths are ../../ because we are now two levels deep (Hypothesis/Gene_ID/)
        ctl_content = f"""
      seqfile = ../../{align_dir}/{gene}
     treefile = ../../{tree_file}
      outfile = {gene_id}.mlc

        noisy = 0      * 0,1,2,3,9: how much junk on screen
      verbose = 0      * 0: concise; 1: detailed; 2: too much
      runmode = 0      * 0: user tree; 1: semi-automatic; 2: automatic
      seqtype = 1      * 1:codons; 2:AAs; 3:reversely translated AAs
    CodonFreq = 2      * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        model = 2      * 0:one omega; 1:many omegas; 2:foreground vs background
      NSsites = 0      * 0:one omega; 1:neutral; 2:selection
        icode = 0      * 0:universal code; 1:mammalian mt; 2-10:others

    fix_kappa = 0      * 0:estimate kappa; 1:fix kappa
        kappa = 2      * initial or fixed kappa
    fix_omega = 0      * 0:estimate omega; 1:fix omega
        omega = 0.5    * initial or fixed omega
"""
        with open(ctl_path, "w") as f:
            f.write(ctl_content)

print("\nDone! Every gene now has its own folder and .ctl file.")
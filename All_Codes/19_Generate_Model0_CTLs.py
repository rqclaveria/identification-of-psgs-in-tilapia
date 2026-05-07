import os

# --- CONFIGURATION ---
align_dir = "Final_Codon_Alignments"
tree_file = "final_species_tree.newick"

genes = [f for f in os.listdir(align_dir) if f.endswith(".codon.fa") or f.endswith(".fasta")]

# Parent folder for the Model 0 (Null) results
output_parent = "Model_0_Results"
os.makedirs(output_parent, exist_ok=True)

print(f"Generating gene folders and Model 0 ctl files...")

for gene in genes:
    # Use the full filename or strip extension for the folder name
    gene_id = gene.replace(".codon.fa", "").replace(".fasta", "")
    
    # Create a specific folder for EACH gene
    gene_folder = os.path.join(output_parent, gene_id)
    os.makedirs(gene_folder, exist_ok=True)
    
    # Path for the ctl file inside that gene folder
    ctl_path = os.path.join(gene_folder, "codeml.ctl")
    
    # Build the PAML Control File content for Model 0
    ctl_content = f"""
      seqfile = ../../{align_dir}/{gene}
     treefile = ../../{tree_file}
      outfile = {gene_id}_m0.mlc

        noisy = 0      * 0,1,2,3,9: how much junk on screen
      verbose = 0      * 0: concise; 1: detailed; 2: too much
      runmode = 0      * 0: user tree; 1: semi-automatic; 2: automatic
      seqtype = 1      * 1:codons; 2:AAs; 3:reversely translated AAs
    CodonFreq = 2      * 2: F3X4 (Accounts for codon usage bias)
        model = 0      * 0: ONE GLOBAL OMEGA (Null Model)
      NSsites = 0      * 0: one omega
        icode = 0      * 0: universal code

    fix_kappa = 0      * 0: estimate kappa
        kappa = 2      * initial kappa
    fix_omega = 0      * 0: estimate omega
        omega = 0.5    * initial omega     
"""
    with open(ctl_path, "w") as f:
        f.write(ctl_content)

print(f"\nDone! Model 0 control files generated in {output_parent}.")
#!/bin/bash

# Define the base directories
LIST_DIR="Null_Candidates"
CODON_DIR="Final_Codon_Alignments"
OUT_BASE="Model2_Null"

# Create the main output directory
mkdir -p "$OUT_BASE"

# Loop through each strain list in the folder
for list_file in "$LIST_DIR"/*.txt; do
    
    # Get the strain name (e.g., GIFTW) and lowercase version for the tree file
    strain=$(basename "$list_file" .txt)
    strain_lower=$(echo "$strain" | tr '[:upper:]' '[:lower:]')
    tree_file="${strain_lower}_tree.newick"
    
    echo "Processing Strain: $strain (Tree: $tree_file)"
    
    # Create a subfolder for this specific strain
    mkdir -p "$OUT_BASE/${strain}_Model2_Null"
    
    # Read each gene ID from the list
    while read -r gene; do
        
        # Define gene-specific folder and file names
        gene_dir="$OUT_BASE/${strain}_Model2_Null/$gene"
        mkdir -p "$gene_dir"
        
        # Path to the codon alignment
        # Assuming your IDs in the txt are like OGXXXX and file is OGXXXX.codon.fa
        codon_path="../../../$CODON_DIR/${gene}.codon.fa"
        tree_path="../../../$tree_file"
        
        # Create the codeml.ctl file inside the gene directory
        cat <<EOF > "$gene_dir/codeml.ctl"
      seqfile = $codon_path
     treefile = $tree_path
      outfile = mlc           * main result file

        noisy = 0             * 0,1,2,3,9: how much rubbish on the screen
      verbose = 0             * 0: concise; 1: detailed, 2: too much
      runmode = 0             * 0: user tree;  1: semi-automatic;  2: automatic
      seqtype = 1             * 1:codons; 2:AAs; 3:codons-->AAs
    CodonFreq = 2             * 0:1/61; 1:F1X4; 2:F3X4; 3:codon table
        model = 2             * 2: branch-site or branch-specific
      NSsites = 0             * 0: one w; 1:neutral; 2:selection; 3:discrete
        icode = 0             * 0:universal code; 1:mammalian mt; etc.
    fix_kappa = 0             * 0:estimate kappa; 1:fix kappa
        kappa = 2             * initial or fixed kappa
    fix_omega = 1             * 1: FIX OMEGA (This is the Null Test)
        omega = 1             * fixed value for the foreground omega
EOF

    done < "$list_file"
done

echo "Done! All directories and ctl files created in $OUT_BASE/"
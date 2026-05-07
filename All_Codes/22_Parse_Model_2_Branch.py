import os
import re
import pandas as pd

# --- Configuration ---
folders = ['Branch_Runs_GST', 'Branch_Runs_GIFTW', 'Branch_Runs_AqCor', 'Branch_Runs_AqAm']
strain_to_samples = {
    'GIFTW': ['SRR33475987', 'SRR33475961'],
    'AqAm': ['SRR11842924', 'SRR11842889'],
    'AqCor': ['SRR11842903', 'SRR11842902'],
    'GST': ['ERR2752240', 'ERR2752210']
}

def parse_combined_mlc(file_path, target_samples):
    with open(file_path, 'r') as f:
        content = f.read()

    # 1. Extract Log Likelihood (lnL)
    lnL_match = re.search(r"lnL\(.*?\):\s+(-?\d+\.\d+)", content)
    lnL = float(lnL_match.group(1)) if lnL_match else None

    # 2. Extract Omega (w) - Grabbing the second value (foreground #1)
    omega_match = re.search(r"w \(dN/dS\) for branches:\s+[\d.]+\s+([\d.]+)", content)
    omega = float(omega_match.group(1)) if omega_match else None

    # 3. Extract Foreground-Specific dN and dS from Tree Blocks
    fg_dn = None
    fg_ds = None

    # Extract the dN and dS tree sections
    dn_tree_match = re.search(r'dN tree:\n(.*?);', content, re.DOTALL)
    ds_tree_match = re.search(r'dS tree:\n(.*?);', content, re.DOTALL)

    if target_samples:
        for sample in target_samples:
            # Regex to find: SampleName, optional #1 label, then the value after the colon
            val_pattern = rf'{sample}(?:\s*#[\d\.]+)?:\s*([\d\.]+)'
            
            if dn_tree_match and fg_dn is None:
                dn_val = re.search(val_pattern, dn_tree_match.group(1))
                if dn_val: fg_dn = float(dn_val.group(1))
            
            if ds_tree_match and fg_ds is None:
                ds_val = re.search(val_pattern, ds_tree_match.group(1))
                if ds_val: fg_ds = float(ds_val.group(1))
            
            # If we found both for at least one sample in the strain, we can stop
            if fg_dn is not None and fg_ds is not None:
                break

    return lnL, fg_dn, fg_ds, omega

# --- Execution ---
data = []
print("Starting combined PAML parsing (Stats + Branch Lengths)...")

for folder in folders:
    if not os.path.exists(folder):
        print(f"Skipping {folder}: Path not found.")
        continue
    
    strain_id = folder.replace('Branch_Runs_', '')
    samples = strain_to_samples.get(strain_id)
    print(f"Processing {strain_id}...")

    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".mlc"):
                full_path = os.path.join(root, file)
                gene_id = os.path.basename(root).replace('.codon', '')
                
                try:
                    lnL, dN, dS, omega = parse_combined_mlc(full_path, samples)
                    data.append({
                        'Hypothesis': strain_id,
                        'Gene': gene_id,
                        'lnL': lnL,
                        'fg_dN': dN,
                        'fg_dS': dS,
                        'omega': omega
                    })
                except Exception as e:
                    print(f"Error parsing {gene_id} in {strain_id}: {e}")

# --- Export ---
df = pd.DataFrame(data)
df.to_csv('paml_master_results.csv', index=False)
print(f"\nSuccess! Created 'paml_master_results.csv' with {len(df)} entries.")
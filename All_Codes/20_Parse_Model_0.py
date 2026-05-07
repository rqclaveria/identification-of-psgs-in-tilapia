import os
import re
import pandas as pd

# Path relative to where you are
target_folder = 'Model_0_Results'

def parse_model0_mlc(file_path):
    """Extracts lnL, dN, dS, and global omega from a Model 0 'mlc' file (v4.10.9)."""
    with open(file_path, 'r') as f:
        content = f.read()

    # 1. Extract Log Likelihood (lnL)
    lnL_match = re.search(r"lnL\(.*?\):\s+(-?\d+\.\d+)", content)
    lnL = float(lnL_match.group(1)) if lnL_match else None

    # 2. Extract global omega (w)
    # Using a more flexible regex for spaces
    omega_match = re.search(r"omega\s*\(dN/dS\)\s*=\s*([\d.]+)", content)
    omega = float(omega_match.group(1)) if omega_match else None

    # 3. Extract tree lengths
    dn_match = re.search(r"tree length for dN:\s+([\d.]+)", content)
    ds_match = re.search(r"tree length for dS:\s+([\d.]+)", content)
    
    dN = float(dn_match.group(1)) if dn_match else None
    dS = float(ds_match.group(1)) if ds_match else None

    return lnL, dN, dS, omega

data = []

# Absolute path for MacBook reliability
abs_base_path = os.path.abspath(target_folder)

if not os.path.exists(abs_base_path):
    print(f"Error: Cannot find {abs_base_path}")
else:
    print(f"Scanning {target_folder} for .mlc files...")
    files_processed = 0

    for root, dirs, files in os.walk(abs_base_path):
        for file in files:
            # UPDATED: Look for files ending in .mlc instead of exactly 'mlc'
            if file.endswith(".mlc"):
                files_processed += 1
                full_path = os.path.join(root, file)
                
                # Extract Gene ID (removes .codon from folder name or _m0.mlc from filename)
                # If your gene is OG0012385_m0.mlc, this captures OG0012385
                gene_id = file.split('_')[0] 
                
                try:
                    lnL, dN, dS, omega = parse_model0_mlc(full_path)
                    
                    if lnL is not None:
                        data.append({
                            'Model': 'Model_0',
                            'Gene': gene_id,
                            'lnL': lnL,
                            'dN': dN,
                            'dS': dS,
                            'omega': omega
                        })
                except Exception as e:
                    print(f"Error parsing {file}: {e}")

# Save to CSV
df = pd.DataFrame(data)
if not df.empty:
    df.to_csv('model0_results_summary_final.csv', index=False)
    print(f"Success! Parsed {len(df)} genes into model0_results_summary_final.csv")
else:
    print(f"Failed to extract data. Found {files_processed} .mlc files, but regex didn't match.")
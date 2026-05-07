#!/bin/bash

BASE_DIR="Model2_Null"

for strain_path in "$BASE_DIR"/*_Model2_Null; do
    
    strain=$(basename "$strain_path" _Model2_Null)
    output_file="New_lnL_Model_2_null_${strain}.csv"
    
    echo "Extracting data for $strain..."
    
    echo "Gene,lnL" > "$output_file"

    find "$strain_path" -name "mlc" | while read -r mlc_file; do
        gene_id=$(basename $(dirname "$mlc_file"))
        
        # 2. Extract the lnL value 
        # This looks for the line, splits by the close-paren ')', 
        # then grabs the first number after the colon.
        lnl_val=$(grep "lnL(ntime:" "$mlc_file" | awk -F')' '{print $2}' | awk -F':' '{print $2}' | awk '{print $1}')
        
        # 3. Append to file if value exists
        if [ ! -z "$lnl_val" ]; then
            echo "$gene_id,$lnl_val" >> "$output_file"
        fi
    done
    
    echo "Created $output_file"
done
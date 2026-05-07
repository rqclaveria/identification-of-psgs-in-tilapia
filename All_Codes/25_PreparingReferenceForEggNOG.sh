for list in PSGs/*_p05_List.txt; do
    while read -r gene; do
        if [ -f "Single_Copy_FASTAs/${gene}.fa" ]; then
            cp -n "Single_Copy_FASTAs/${gene}.fa" Eggnog/
        else
            cp -n Single_Copy_FASTAs/${gene}*.fa Eggnog/ 2>/dev/null
        fi
    done < "$list"
done


for file in Eggnog/OG*.fa; do
    og_id=$(basename "$file" .fa)
    echo ">$og_id" >> Merged_Reference_Genes.fasta
    awk '/^>/{count++} count==9 && !/^>/{print}' "$file" >> Merged_Reference_Genes.fasta
done
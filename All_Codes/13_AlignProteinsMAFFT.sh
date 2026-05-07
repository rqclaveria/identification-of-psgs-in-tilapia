mkdir -p Aligned_FASTAs

find Single_Copy_FASTAs -name "*.fa" | xargs -n 1 -P 4 -I {} sh -c '
    out="Aligned_FASTAs/$(basename {})"
    mafft --auto --quiet "{}" > "$out"
    echo "Aligned: $out"
'
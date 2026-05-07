mkdir -p DNA_Renamed_Simple

for f in Species_DNA/*.{fasta,fa}; do
    [ -e "$f" ] || continue

    fname=$(basename "$f" .fasta)
    fname=${fname%.fa}

    sample=${fname%%_*}
    species=$(echo "$fname" | cut -d'_' -f2)

    awk -v s="$sample" -v sp="$species" '
    /^>/ {
        header=$0

        # remove ">"
        sub(/^>/, "", header)

        # split gene and genomic info
        split(header, a, "::")
        gene=a[1]
        rest=a[2]

        # extract chr, coords, strand
        match(rest, /(.*):([0-9]+-[0-9]+)\((.)\)/, m)

        chr=m[1]
        coord=m[2]
        strand=m[3]

        print ">" s "_" sp "_" gene "__" chr "_" coord "_" strand "_"
        next
    }
    { print }
    ' "$f" > DNA_Renamed_Simple/"$fname.fasta"

done
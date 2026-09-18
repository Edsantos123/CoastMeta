################################################
# PREPARE BINS FOR BAT
################################################

rule prepare_bat_bins:
    input:
        archaea = TIARA_DIR / "results/archaea.fasta",
        bacteria = TIARA_DIR / "results/bacteria.fasta"
    output:
        directory(
            CAT_BAT_DIR / "bat_bins"
        )
    shell:
        r"""
        mkdir -p {output}

        rm -f {output}/*.fna

        cat {input.archaea} {input.bacteria} |
        awk '
        /^>/ {{
            header=$0
            sub(/^>/, "", header)

            n=split(header, parts, "|")

            if (n >= 3) {{

                tool=parts[1]
                bin=parts[2]

                outfile="{output}/" tool "_" bin ".fna"

                print ">" parts[3] >> outfile
            }}

            next
        }}

        {{
            if (outfile != "")
                print >> outfile
        }}
        '

        find {output} \
            -type f \
            -size 0 \
            -delete
        """
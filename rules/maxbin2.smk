
rule depth_to_maxbin_abundance:
    input:
        depth = MAPPING_DIR / "depth.txt"
    output:
        abundance = MAPPING_DIR / "contigs.maxbin.abundance.txt"
    shell:
        """
        awk 'NR>1 {{print $1"\\t"$3}}' {input.depth} > {output.abundance}
        """

MAXBIN_CFG = config.get("binning", {}).get("maxbin2", {})

rule maxbin2:
    input:
        contigs = ASSEMBLY_DIR / "final.contigs.fa",
        abundance = MAPPING_DIR / "contigs.maxbin.abundance.txt" 
       
    output:
        bins = directory(BINNING_DIR / "maxbin2"),
        done = BINNING_DIR / "maxbin2/.finished", 
        status = BINNING_DIR / "maxbin2/status.txt"

    threads: MAXBIN_CFG.get("threads", 4)
    shell:
        """
        mkdir -p {output.bins}

        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -w /data  \
            maxbin2_image \
            -contig /data/{input.contigs} \
            -abund /data/{input.abundance} \
            -out /data/{output.bins}/bin \
            -thread {threads} && \
        
        if find {output.bins} -maxdepth 1 -type f \
             -regextype posix-extended \
            -regex '.*/bin\.[0-9]+\.fa' | grep -q .; then
            echo "SUCCESS" > {output.status}
        else
            echo "NO_BINS" > {output.status}
        fi
        touch {output.done}
        """

      
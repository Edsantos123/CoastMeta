BINNING_CFG = config.get("binning", {}).get("metabat2", {})

rule metabat2:
    input:
        contigs = ASSEMBLY_DIR / "final.contigs.fa",
        depth = MAPPING_DIR / "depth.txt"
    output:
        bins = directory(BINNING_DIR / "metabat2"),
        done = BINNING_DIR / "metabat2/.finished", 
        status = BINNING_DIR / "metabat2/status.txt"
    threads: BINNING_CFG.get("threads", 4) 
    params: 
        min_contig = BINNING_CFG.get("min_contig", 2000),
        min_bin_size = BINNING_CFG.get("min_bin_size", 200000),
        seed = BINNING_CFG.get("seed", 123),
        unbinned = "--unbinned" if BINNING_CFG.get("unbinned", True) else "", 
        min_cv = BINNING_CFG.get("min_cv", 1),
        min_cvsun = BINNING_CFG.get("min_cvsun", 1), 
        maxp = BINNING_CFG.get("maxp", 95),
        mins = BINNING_CFG.get("mins", 60), 
        min_small_contig = BINNING_CFG.get("min_small_contig", 1000)

    shell:
        """
        mkdir -p {output.bins}

        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data metabat/metabat:v2.18-11-g0434d21 \
            metabat2 \
            -i /data/{input.contigs} \
            -a /data/{input.depth} \
            -o /data/{output.bins}/bin \
            -m {params.min_contig} \
            -s {params.min_bin_size} \
            --seed {params.seed} \
            {params.unbinned} \
            -x {params.min_cv} \
            --minCVSum {params.min_cvsun} \
            --maxP {params.maxp} \
            --minS {params.mins} \
            --minSmallContig {params.min_small_contig} \
            -t {threads} && \
        
        if find {output.bins} -maxdepth 1 -type f \
            -regextype posix-extended \
            -regex '.*/bin\.[0-9]+\.fa' | grep -q .; then
            echo "SUCCESS" > {output.status}
        else
            echo "NO_BINS" > {output.status}
        fi
        touch {output.done}
        """
 
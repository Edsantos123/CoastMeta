##################################
# MEGAHIT
##################################

MEGAHIT_CFG = config.get("megahit", {})

rule megahit:
    input:
        r1 = ASSEMBLY_INPUT_R1,
        r2 = ASSEMBLY_INPUT_R2
    output:
        contigs = ASSEMBLY_DIR / "final.contigs.fa"
    threads: MEGAHIT_CFG.get("threads", 8)
    params:
        k_list     = MEGAHIT_CFG.get("k_list", "21,41,61,81"),
        min_contig = MEGAHIT_CFG.get("min_contig", 500),
    shell:
        """
        rm -rf {ASSEMBLY_DIR}

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data megahit_image \
          -1 /data/{input.r1} \
          -2 /data/{input.r2} \
          -o /data/{ASSEMBLY_DIR} \
          -t {threads}
        """

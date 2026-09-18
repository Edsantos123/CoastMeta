##################################
# REPAIR — BBTOOLS
##################################

REPAIR_CFG = config.get("repair", {})

rule repair:
    input:
        r1 = REPAIR_INPUT_R1,
        r2 = REPAIR_INPUT_R2
    output:
        r1 = REPAIR_DIR / "read_1.fastq.gz",
        r2 = REPAIR_DIR / "read_2.fastq.gz",
        singletons = REPAIR_DIR / "singletons.fastq.gz"
    threads: REPAIR_CFG.get("threads", 4)
    params:
        memory = REPAIR_CFG.get("memory", "4g")
    shell:
        """
        mkdir -p {REPAIR_DIR}

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data bbtools_image \
            -Xmx{params.memory} \
            in1=/data/{input.r1} \
            in2=/data/{input.r2} \
            out1=/data/{output.r1} \
            out2=/data/{output.r2} \
            outs=/data/{output.singletons} \
            threads={threads} \
            overwrite=true
        """
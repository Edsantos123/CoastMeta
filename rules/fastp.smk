##################################
# FASTP
##################################

FASTP_CFG = config.get("fastp", {})

rule fastp:
    input:
        r1 = RAW_DIR / "read_1.fastq.gz",
        r2 = RAW_DIR / "read_2.fastq.gz"
    output:
        r1   = FASTP_DIR / "read_1_clean.fastq.gz",
        r2   = FASTP_DIR / "read_2_clean.fastq.gz",
        html = FASTP_DIR / "fastp.html",
        json = FASTP_DIR / "fastp.json"
        
    threads: FASTP_CFG.get("threads", 4)
    params:
        cut_q      = FASTP_CFG.get("cut_q", 30),
        min_len    = FASTP_CFG.get("min_len", 50),
        max_unqual = FASTP_CFG.get("max_unqual_pct", 40),
        adapter_flag = "--detect_adapter_for_pe" if FASTP_CFG.get("detect_adapter", True) else ""
    shell:
        """
        mkdir -p {FASTP_DIR}

        docker run --rm -u $(id -u):$(id -g) -v $(pwd):/data fastp_image \
          -i /data/{input.r1} \
          -I /data/{input.r2} \
          -o /data/{output.r1} \
          -O /data/{output.r2} \
          -h /data/{output.html} \
          -j /data/{output.json} \
          --qualified_quality_phred {params.cut_q} \
          --length_required {params.min_len} \
          --unqualified_percent_limit {params.max_unqual} \
          {params.adapter_flag} \
          --thread {threads} 
        """
##################################
# BWA INDEX
##################################

BWA_CFG = config.get("bwa", {})

rule bwa_index:
    input:
        HOST_FASTA
    output:
        expand(
            "{ref}.{ext}",
            ref=str(HOST_FASTA),
            ext=["bwt","pac","ann","amb","sa"]
          )
    shell:
        """
        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data bwa_image \
          bwa index /data/{input}
        """
##################################
# HOST REMOVAL
##################################

rule host_removal:
    input:
        r1 = HOST_INPUT_R1,
        r2 = HOST_INPUT_R2,
        idx = HOST_FASTA.with_suffix(HOST_FASTA.suffix + ".bwt")
    output:
        r1    = HOST_DIR / "read_1.fastq.gz",
        r2    = HOST_DIR / "read_2.fastq.gz",
        stats = HOST_DIR / "flagstat.txt"
    threads: BWA_CFG.get("threads", 8)
    params:
      seed_length      = BWA_CFG.get("seed_length", 19),
      mismatch_penalty = BWA_CFG.get("mismatch_penalty", 4),
      secondary_flag   = "-M" if BWA_CFG.get("mark_secondary", False) else ""
    shell:
        """
        mkdir -p {HOST_DIR} {TMP_DIR}

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data bwa_image \
          mem -t {threads} \
          -k {params.seed_length} \
          -B {params.mismatch_penalty} \
          {params.secondary_flag} \
          /data/{HOST_FASTA} \
          /data/{input.r1} /data/{input.r2} \
          > /data/{TMP_DIR}/aln.sam

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data samtools_image \
          view -b /data/{TMP_DIR}/aln.sam | \
          flagstat - > /data/{output.stats}

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data samtools_image \
          view -b -f 12 /data/{TMP_DIR}/aln.sam | \
          sort -n -o /data/{TMP_DIR}/unmapped.bam

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data samtools_image \
          fastq \
            -1 /data/{output.r1} \
            -2 /data/{output.r2} \
            /data/{TMP_DIR}/unmapped.bam

        rm -rf {TMP_DIR}
        """
##################################
# FASTQC — RAW
##################################

rule fastqc_raw:
    input:
        r1 = RAW_DIR / "read_1.fastq.gz",
        r2 = RAW_DIR / "read_2.fastq.gz"
    output:
        html1 = FASTQC_RAW_DIR / "read_1_fastqc.html",
        zip1  = FASTQC_RAW_DIR / "read_1_fastqc.zip",
        html2 = FASTQC_RAW_DIR / "read_2_fastqc.html",
        zip2  = FASTQC_RAW_DIR / "read_2_fastqc.zip"
    shell:
        """
        mkdir -p {FASTQC_RAW_DIR}

        docker run --rm -u $(id -u):$(id -g) -v $(pwd):/data fastqc_image \
          /data/{input.r1} /data/{input.r2} \
          -o /data/{FASTQC_RAW_DIR}
        """
##################################
# FASTQC — CLEAN
##################################

rule fastqc_clean:
    input:
        r1 = FASTP_DIR / "read_1_clean.fastq.gz",
        r2 = FASTP_DIR / "read_2_clean.fastq.gz"
    output:
        html1 = FASTQC_CLEAN_DIR / "read_1_clean_fastqc.html",
        zip1  = FASTQC_CLEAN_DIR / "read_1_clean_fastqc.zip",
        html2 = FASTQC_CLEAN_DIR / "read_2_clean_fastqc.html",
        zip2  = FASTQC_CLEAN_DIR / "read_2_clean_fastqc.zip"
    shell:
        """
        mkdir -p {FASTQC_CLEAN_DIR}

        docker run --rm -u $(id -u):$(id -g) -v $(pwd):/data fastqc_image \
          /data/{input.r1} /data/{input.r2} \
          -o /data/{FASTQC_CLEAN_DIR}
        """
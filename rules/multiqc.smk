##################################
# MULTIQC — SINGLE SAMPLE
##################################

def multiqc_inputs(wc):
    files = []

    # FastQC — RAW
    files += [
	FASTQC_RAW_DIR / "read_1_fastqc.zip",
	FASTQC_RAW_DIR / "read_2_fastqc.zip",
    ]

    # FastQC — CLEAN + Fastp
    if USE_FASTP:
        files += [
            FASTQC_CLEAN_DIR / "read_1_clean_fastqc.zip",
	    FASTQC_CLEAN_DIR / "read_2_clean_fastqc.zip",
            FASTP_DIR / "fastp.json",
	
        ]

    # Host removal
    if USE_HOST:
        files += [
            HOST_DIR / "flagstat.txt",
        ]

    return files


rule multiqc:
    input:
        multiqc_inputs
    output:
        MULTIQC_DIR / "multiqc_report.html"
    shell:
        """
        mkdir -p {MULTIQC_DIR} 

        docker run --rm -u $(id -u):$(id -g) \
          -v $(pwd):/data multiqc_image \
          /data/output/dados -o /data/{MULTIQC_DIR} 
        """

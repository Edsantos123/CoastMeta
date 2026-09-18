#=========================================================
# Indexação dos contigs 
#=========================================================
rule bwa_index_mapping:
    input:
        ASSEMBLY_DIR / "final.contigs.fa"
    output:
         expand(
            str(ASSEMBLY_DIR / "final.contigs.fa.{ext}"),
            ext=["amb","ann","bwt","pac","sa"]
          )
    threads: 2
    shell:
        """
        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data bwa_image \
            index /data/{input}
            
        """
#=========================================================
# Mapeamento dos contigs contra os reads
#=========================================================
rule bwa_map_sorted:
    input: 
        contigs = ASSEMBLY_DIR / "final.contigs.fa",
        r1 = BINNING_INPUT_R1,
        r2 = BINNING_INPUT_R2,
        idx = expand (
            str(ASSEMBLY_DIR / "final.contigs.fa.{ext}"),
            ext = ["amb", "ann", "bwt", "pac", "sa"]
        )
    output:  
        bam = MAPPING_DIR / "contigs.sorted.bam",
        bai = MAPPING_DIR / "contigs.sorted.bam.bai" 
    threads: 2
    shell:
        """
        mkdir -p {MAPPING_DIR}
        
        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data bwa_image \
            mem -t {threads} /data/{input.contigs} /data/{input.r1} /data/{input.r2} \
            > {MAPPING_DIR}/tmp.sam
    
        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data samtools_image \
            view -b /data/{MAPPING_DIR}/tmp.sam \
            > {MAPPING_DIR}/tmp.bam

         docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data samtools_image \
            sort -@ {threads} \
            -o /data/{output.bam} \
            /data/{MAPPING_DIR}/tmp.bam

        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data samtools_image \
            index /data/{output.bam}

            rm {MAPPING_DIR}/tmp.sam {MAPPING_DIR}/tmp.bam

        """

#=========================================================
# Geração do mapeamento 
#=========================================================
DEPTH_CFG = config.get("jgi_summarize_bam_contig_depths", {})

rule depth:
    input:
        bam = MAPPING_DIR / "contigs.sorted.bam",
        contigs = ASSEMBLY_DIR / "final.contigs.fa"
    output:
        MAPPING_DIR / "depth.txt"
    params: 
        min_mapq = DEPTH_CFG.get("min_mapq", 10), 
        pid = DEPTH_CFG.get("percent_identity", 97)
    shell:
        """
        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data metabat/metabat:v2.18-11-g0434d21 \
            jgi_summarize_bam_contig_depths \
            --outputDepth /data/{output} /data/{input.bam} \
            --minMapQual {params.min_mapq}  \
            --percentIdentity {params.pid}  \
            --referenceFasta /data/{input.contigs} \
        
        """


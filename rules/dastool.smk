rule convert_metabat2:
    input:
        done = BINNING_DIR / "metabat2/.finished"
    output:
        contigs2bin = BINNING_DIR / "metabat2.contigs2bin.tsv"
    log:
        BINNING_DIR / "logs/metabat2.contigs2bin.log"
    shell:
        r"""
        BIN_DIR=$(dirname {input.done})

        mkdir -p $(dirname {log})

        docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -w /data/$BIN_DIR \
            dastool_image \
            Fasta_to_Contig2Bin.sh -i . -e fa \
        > {output.contigs2bin} 2>> {log}
        """
rule convert_maxbin2:
    input:
        done = BINNING_DIR / "maxbin2/.finished"
    output:
        contigs2bin = BINNING_DIR / "maxbin2.contigs2bin.tsv"
    log:
        BINNING_DIR / "logs/maxbin2.contigs2bin.log"
    shell:
        r"""
        BIN_DIR=$(dirname {input.done})

        mkdir -p $(dirname {log})

        docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -w /data/$BIN_DIR \
            dastool_image \
            Fasta_to_Contig2Bin.sh -i . -e fasta \
        > {output.contigs2bin} 2>> {log}
        """
DASTOOL_CFG = config.get("binning", {}).get("dastool", {}) 

rule dastool:
    input:
        contigs = ASSEMBLY_DIR / "final.contigs.fa",
        metabat = BINNING_DIR / "metabat2.contigs2bin.tsv",
        maxbin = BINNING_DIR / "maxbin2.contigs2bin.tsv"
    output:
        bins = directory(BINNING_DIR / "dastool"),
        done = BINNING_DIR / "dastool/.finished"
    threads: DASTOOL_CFG.get("threads", 4)
    shell:
        r"""
        mkdir -p {output.bins}

        docker run --rm -u $(id -u):$(id -g) \
            -v $(pwd):/data dastool_image  \
            DAS_Tool \
            -i /data/{input.metabat},/data/{input.maxbin} \
            -l metabat2,maxbin2 \
            -c /data/{input.contigs} \
            -o /data/{output.bins}/dastool \
            -t {threads} 

        touch {output.done}
        """
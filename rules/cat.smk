################################################
# CAT
################################################

rule prepare_cat_input:
    input:
        archaea = TIARA_DIR / "results/archaea.fasta",
        bacteria = TIARA_DIR / "results/bacteria.fasta"
    output:
        fasta = CAT_BAT_DIR / "input/cat_input.fasta"
    shell:
        r"""
        mkdir -p $(dirname {output.fasta})

        cat {input.archaea} {input.bacteria} > {output.fasta}
        """
rule cat:
    input:
        contigs = CAT_BAT_DIR / "input/cat_input.fasta"
    output:
        classification = CAT_BAT_DIR / "cat.contig2classification.txt",
        orf2lca = CAT_BAT_DIR / "cat.ORF2LCA.txt",
        proteins = CAT_BAT_DIR / "cat.predicted_proteins.faa",
        gff = CAT_BAT_DIR / "cat.predicted_proteins.gff",
        finished = CAT_BAT_DIR / "cat.finished"
    log:
        CAT_BAT_DIR / "logs/cat.log"
    threads:
        config.get("cat_bat", {}).get("threads", 3)
    params:
        database_dir = Path(
            config["cat_bat"]["database"]
        ),
        cat_range = config.get(
            "cat_bat", {}
        ).get("cat", {}).get("range", 10),
        fraction = config.get(
            "cat_bat", {}
        ).get("cat", {}).get("fraction", 0.50),
        block_size = config.get(
            "cat_bat", {}
        ).get("cat", {}).get("block_size", 1),
        index_chunks = config.get(
            "cat_bat", {}
        ).get("cat", {}).get("index_chunks", 4)
    shell:
        r"""
        mkdir -p $(dirname {output.finished})
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            cat_image \
            contigs \
            -c /data/{input.contigs} \
            -d /db/db \
            -t /db/tax \
            -o /data/{CAT_BAT_DIR}/cat \
            -r {params.cat_range} \
            -f {params.fraction} \
            -n {threads} \
            --index_chunks {params.index_chunks} \
            --block_size {params.block_size} \
            > {log} 2>&1
        then
            exit 1
        fi

        touch {output.finished}
        """
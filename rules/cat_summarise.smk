################################################
# CAT - SUMMARISE
################################################

rule cat_summarise:
    input:
        contigs =
            CAT_BAT_DIR / "input/cat_input.fasta",
        named =
            CAT_BAT_DIR /
            "cat.contig2classification.named.txt"
    output:
        summary =
            CAT_BAT_DIR / "cat.summary.txt"
    log:
        CAT_BAT_DIR / "logs/cat_summarise.log"
    params:
        database_dir =
            Path(config["cat_bat"]["database"])
    shell:
        r"""
        mkdir -p $(dirname {output.summary})
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            cat_image \
            summarise \
            -c /data/{input.contigs} \
            -i /data/{input.named} \
            -o /data/{output.summary} \
            > {log} 2>&1
        then
            exit 1
        fi
        """
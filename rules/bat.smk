################################################
# BAT
################################################

rule bat:
    input:
        bins =
            CAT_BAT_DIR / "bat_bins"
    output:
        classification =
            CAT_BAT_DIR / "bat.bin2classification.txt",
        orf2lca =
            CAT_BAT_DIR / "bat.ORF2LCA.txt",
        finished =
            CAT_BAT_DIR / "bat.finished"
    log:
        CAT_BAT_DIR / "logs/bat.log"
    threads:
        config.get(
            "cat_bat", {}
        ).get("threads", 3)
    params:
        database_dir =
            Path(config["cat_bat"]["database"]),
        bin_suffix =
            config.get(
                "cat_bat", {}
            ).get("bat", {})
            .get("bin_suffix", ".fna"),
        bat_range =
            config.get(
                "cat_bat", {}
            ).get("bat", {})
            .get("range", 5),
        fraction =
            config.get(
                "cat_bat", {}
            ).get("bat", {})
            .get("fraction", 0.30),
        block_size =
            config.get(
                "cat_bat", {}
            ).get("bat", {})
            .get("block_size", 1),
        index_chunks =
            config.get(
                "cat_bat", {}
            ).get("bat", {})
            .get("index_chunks", 4)
    shell:
        r"""
        mkdir -p $(dirname {output.finished})
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            cat_image \
            bins \
            -b /data/{input.bins} \
            -d /db/db \
            -t /db/tax \
            -s {params.bin_suffix} \
            -o /data/{CAT_BAT_DIR}/bat \
            -r {params.bat_range} \
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
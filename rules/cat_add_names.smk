################################################
# CAT - ADD NAMES
################################################

rule cat_add_names:
    input:
        classification = CAT_BAT_DIR / "cat.contig2classification.txt"
    output:
        named = CAT_BAT_DIR / "cat.contig2classification.named.txt"
    log:
        CAT_BAT_DIR / "logs/cat_add_names.log"
    params:
        database_dir = Path(
            config["cat_bat"]["database"]
        ),
        only_official = (
            "--only_official"
            if config.get("cat_bat", {})
            .get("add_names", {})
            .get("only_official", True)
            else ""
        ),
        exclude_scores = (
            "--exclude_scores"
            if config.get("cat_bat", {})
            .get("add_names", {})
            .get("exclude_scores", False)
            else ""
        )
    shell:
        r"""
        mkdir -p $(dirname {output.named})
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            cat_image \
            add_names \
            -i /data/{input.classification} \
            -o /data/{output.named} \
            -t /db/tax \
            {params.only_official} \
            {params.exclude_scores} \
            > {log} 2>&1
        then
            exit 1
        fi
        """
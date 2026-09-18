from pathlib import Path

KAIJU_CFG = config.get("kaiju", {})

KAIJU_DB = Path(KAIJU_CFG["database"])
KAIJU_NODES = Path(KAIJU_CFG["nodes"])
KAIJU_NAMES = Path(KAIJU_CFG["names"])


################################################
# KAIJU
################################################

rule kaiju:
    input:
        r1 = ASSEMBLY_INPUT_R1,
        r2 = ASSEMBLY_INPUT_R2

    output:
        result = KAIJU_DIR / "kaiju.out",
        done = KAIJU_DIR / ".finished"

    log:
        KAIJU_DIR / "logs/kaiju.log"

    threads:
        KAIJU_CFG.get("threads", 3)

    params:
        database_dir = KAIJU_DB.parent,
        database = KAIJU_DB.name,
        nodes = KAIJU_NODES.name

    shell:
        r"""
        mkdir -p {KAIJU_DIR}
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            kaiju_image \
            -t /db/{params.nodes} \
            -f /db/{params.database} \
            -i /data/{input.r1} \
            -j /data/{input.r2} \
            -o /data/{output.result} \
            -z {threads} \
            > {log} 2>&1
        then
            exit 1
        fi

        touch {output.done}
        """


################################################
# KAIJU2TABLE
################################################

rule kaiju2table:
    input:
        kaiju = KAIJU_DIR / "kaiju.out"

    output:
        table = KAIJU_DIR / "kaiju_taxonomy.tsv"

    log:
        KAIJU_DIR / "logs/kaiju2table.log"

    params:
        nodes = KAIJU_NODES.name,
        names = KAIJU_NAMES.name,
        database_dir = KAIJU_DB.parent,
        rank = KAIJU_CFG.get("rank", "genus"),
        use_unclassified = (
            "-u"
            if KAIJU_CFG.get("use_unclassified", False)
            else ""
        )

    shell:
        r"""
        mkdir -p {KAIJU_DIR}
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            --entrypoint kaiju2table \
            -v $(pwd):/data \
            -v {params.database_dir}:/db:ro \
            kaiju_image \
            -t /db/{params.nodes} \
            -n /db/{params.names} \
            -r {params.rank} \
            {params.use_unclassified} \
            -o /data/{output.table} \
            /data/{input.kaiju} \
            > {log} 2>&1
        then
            exit 1
        fi
        """
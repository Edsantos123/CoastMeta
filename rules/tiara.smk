TIARA_CFG = config.get("tiara", {})

rule tiara:
    input:
        fasta = TIARA_DIR / "input/tiara_input.fasta"

    output:
        result = TIARA_DIR / "results/tiara.out", 
        archaea = TIARA_DIR / "results/archaea.fasta",
        bacteria = TIARA_DIR / "results/bacteria.fasta",
        eukarya = TIARA_DIR / "results/eukarya.fasta",
        mitochondrion = TIARA_DIR / "results/mitochondrion.fasta",
        plastid = TIARA_DIR / "results/plastid.fasta"

    log:
        TIARA_DIR / "logs/tiara.log"

    threads:
        TIARA_CFG.get("threads", 4)

    params:
        min_len = TIARA_CFG.get("min_len", 3000),
        prob_cutoff = TIARA_CFG.get("prob_cutoff", "0.65 0.65"), 
        probabilities = "--probabilities" if TIARA_CFG.get("probabilities", False) else ""

    shell:
        r"""
        mkdir -p $(dirname {output.result})
        mkdir -p $(dirname {log})

        docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            tiara_image \
            -i /data/{input.fasta} \
            -o /data/{output.result} \
            -t {threads} \
            -m {params.min_len} \
            -p {params.prob_cutoff} \
            --to_fasta all \
            {params.probabilities} \
            > {log} 2>&1
        
        RESULTS_DIR=$(dirname {output.result})

        for class in archaea bacteria eukarya mitochondrion plastid; do

            case "$class" in
                archaea)
                    SOURCE="$RESULTS_DIR/archaea_tiara_input.fasta"
                    TARGET="{output.archaea}"
                    ;;
                bacteria)
                    SOURCE="$RESULTS_DIR/bacteria_tiara_input.fasta"
                    TARGET="{output.bacteria}"
                    ;;
                eukarya)
                    SOURCE="$RESULTS_DIR/eukarya_tiara_input.fasta"
                    TARGET="{output.eukarya}"
                    ;;
                mitochondrion)
                    SOURCE="$RESULTS_DIR/mitochondrion_tiara_input.fasta"
                    TARGET="{output.mitochondrion}"
                    ;;
                plastid)
                    SOURCE="$RESULTS_DIR/plastid_tiara_input.fasta"
                    TARGET="{output.plastid}"
                    ;;
            esac

            if [ -f "$SOURCE" ]; then
                mv "$SOURCE" "$TARGET"
            else
                touch "$TARGET"
            fi

        done
        """
        